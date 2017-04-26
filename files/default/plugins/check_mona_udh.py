#!/usr/bin/env python

import nagiosplugin
from nagiosplugin.state import Ok
from nagiosplugin.state import Warn
from nagiosplugin.state import Critical
from nagiosplugin.state import Unknown

import argparse
import logging
import re

from datetime import datetime
from dateutil.relativedelta import *

from pymongo import MongoClient
from pymongo.errors import PyMongoError

import requests
from requests.exceptions import RequestException

import json

slack_default_url = 'https://hooks.slack.com/services/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'
#slack_default_channel = '#status_udh_webhook'

class UDH(nagiosplugin.Resource):

   def __init__(self, mona_test_id, rate_context, time_context, check_window_size, check_window_offset):
      self.test = mona_test_id
      self.rc = rate_context
      self.tc = time_context
      self.cw = check_window_size
      self.cwo = check_window_offset

   # and here's the always funny...
   def probe(self):
      
      mongo = MongoClient('mongos-cluster-1.prod1.us-w1.int.ops.tlium.com',27017)
      cfgdb = mongo['ops']['mona_config']
      eventdb = mongo['ops']['mona_events']

      cfg = cfgdb.find_one({"_id" : self.test})

      if cfg:
	 if 'region' in cfg:
	    region = cfg['region']
	 else:
	    region = 'Yonder'

	 if 'batchsize' in cfg:
	    batchsize = cfg['batchsize']
	 else:
	    batchsize = 'N/A'

	 end = datetime.utcnow()
	 end = end - relativedelta(minutes=self.cwo)
	 start = end - relativedelta(minutes=self.cw)

	 # Triple query where one would do... yep, I'm lazy.
	 events_sent = eventdb.find({"test_id" : self.test, "time_sent" : {"$gte" : start, "$lt" : end }})
	 events_recv = eventdb.find({"test_id" : self.test,
	                             "time_sent" : {"$gte" : start, "$lt" : end },
				     "time_recv" : {"$exists" : 1}})
	 event_errors = eventdb.find({"test_id" : self.test,
	                              "time_sent" : {"$gte" : start, "$lt" : end },
				      "error" : {"$exists" : 1}})
	 event_http_ok = eventdb.find({"test_id" : self.test,
	                              "time_sent" : {"$gte" : start, "$lt" : end },
				      "uconnect_status_code" : 200})

	 total_errors = event_errors.count()
	 logging.debug("total_errors %d" % total_errors)

	 total_sent = events_sent.count()
	 logging.debug("total_sent = %d" % total_sent)

	 total_recv = events_recv.count()
	 logging.debug("total_recv = %d" % total_recv)

	 total_http_ok = event_http_ok.count()
	 logging.debug("total_http_ok = %d" % total_http_ok)

	 if total_sent == 0:
	    raise Exception("no test events found for time range %s to %s" % (start.strftime('%c'), end.strftime('%c')))

	 if total_recv == 0:
	    raise Exception("no test events received for time range %s to %s" % (start.strftime('%c'), end.strftime('%c')))

	 failure_rate = 100 - (float(total_recv)/total_sent * 100)
	 http_ok_rate = (float(total_http_ok)/total_sent * 100)

         elapsed = 0
	 for event in events_recv:
	    delta = event['time_recv'] - event['time_sent']
	    elapsed += delta.total_seconds()

	 avg_flight_time = elapsed / total_recv

	 logging.debug("elapsed = %d" % elapsed)
	 logging.debug("avg = %d" % avg_flight_time)

	 yield nagiosplugin.Metric(self.rc, failure_rate, uom='%')
	 yield nagiosplugin.Metric(self.tc, "%.2f" % avg_flight_time, uom='s')
	 yield nagiosplugin.Metric("event errors", total_errors)
	 yield nagiosplugin.Metric("events sent", total_sent)
	 yield nagiosplugin.Metric("events recv", total_recv)
	 yield nagiosplugin.Metric("http ok rate", http_ok_rate, uom='%') 
	 yield nagiosplugin.Metric("test batchsize", batchsize)
	 yield nagiosplugin.Metric("check window start", start.strftime('%c UTC'))
	 yield nagiosplugin.Metric("check window end", end.strftime('%c UTC'))
	 yield nagiosplugin.Metric("region", region)

      else:

	 raise Exception("unknown test identifier: %s" % self.test)


class MonaContext(nagiosplugin.ScalarContext):

   def __init__(self, name, warning=None, critical=None,
                fmt_metric='{name} is {valueunit}', result_cls=nagiosplugin.Result):

      super(MonaContext, self).__init__(name, warning, critical, fmt_metric, result_cls)
      self.warning = float(warning)
      self.critical = float(critical)

   def evaluate(self, metric, resource):

      v = float(metric.value)
      logging.debug("v = %.2f" % v)

      if v > self.critical:
	 return self.result_cls(Critical, "> %.2f" % self.critical, metric)
      elif v > self.warning:
         return self.result_cls(Warn, "> %.2f" % self.warning, metric)
      else:
         return self.result_cls(Ok, None, metric)


class MonaSummary(nagiosplugin.Summary):

   class Ok:
      name = 'OK'
      icon = ':white_check_mark:'
      color = '#36a64f'

   class Warn:
      name = 'WARNING'
      icon = ':warning:'
      color = '#f3d442'

   class Critical:
      name = 'CRITICAL'
      icon = ':rotating_light:'
      color = '#dd2b19'

   def __init__(self, slack_update=False, slack_url='', slack_channel=''):
      self.slack_update = slack_update
      self.slack_url = slack_url
      #self.slack_channel = slack_channel
      super(MonaSummary, self).__init__()

   def __stats(self, results):
      perfs = ""
      for result in results:
	 perf = result.metric.performance()
	 if perf:
	    perf = str(perf)
	    r = re.compile("'.*: ")
	    m = r.match(perf)
	    perf = perf[m.end():]
	    perf = perf.translate(None, "'")
	    perf = perf.replace("=", " = ")
	    perfs += "%s\n" % str(perf)
      return "```%s%s```" % (perfs, self.verbose(results))

   def __slack(self, state, region, metric_desc, stats):
      if (self.slack_update):
	 headers = { 'Content-type': 'application/json' }
	 data = {
	    "link_names": 1,
	    "username": "Mona",
	    "icon_emoji": state.icon,
	    "attachments" : [
	       {
		  "fallback" : metric_desc,
		  "color": state.color,
		  "pretext" : "Webhook Connector Status",
		  "mrkdwn_in": ["text", "pretext", "fields"],
		  "fields": [
		     {
			"title": "Region",
			"value": region,
			"short": False
		     },
		     {
			"title": "Metric",
			"value": metric_desc,
			"short": False
		     },
		     {
			"title": "Status",
			"value": state.name,
			"short": False
		     },
		     {
			"title": "Stats",
			"value": stats,
			"short": False
		     }
		  ]
	       }
	    ]
	 }

	 try:
	    r = requests.post(self.slack_url, headers=headers, data=json.dumps(data), timeout=10)
	 except RequestException as e:
	    logging.error("error: slack update failed: %s" % e)

   def ok(self,results):
      self.__slack(self.Ok, results['region'].metric.value, str(results.first_significant), self.__stats(results))
      return super(MonaSummary, self).ok(results)

   def problem(self,results):
      if results.most_significant_state == nagiosplugin.state.Critical:
	 state = self.Critical
      elif results.most_significant_state == nagiosplugin.state.Warn:
	 state = self.Warn
      else:
	 state = None
      if state:
	 self.__slack(state, results['region'].metric.value, str(results.first_significant), self.__stats(results))
      return super(MonaSummary, self).problem(results)

   def verbose(self, results):
      msg = "check window start time: %s\n" % results['check window start'].metric.value
      msg += "check window end time: %s\n" % results['check window end'].metric.value
      msg += "events sent during check window: %d\n" % results['events sent'].metric.value
      msg += "events recv during check window: %d\n" % results['events recv'].metric.value
      msg += "event errors during check window: %d\n" % results['event errors'].metric.value
      msg += "uconnect http ok rate: %.2f%%\n" % results['http ok rate'].metric.value
      msg += "configured test batchsize: %d\n" % results['test batchsize'].metric.value
      return msg
      

@nagiosplugin.guarded()
def main():
   argp = argparse.ArgumentParser(description=__doc__)
   argp.add_argument('-w', '--warning', metavar='RATE', default=5,
                     help='return warning if failure percentage is higher than RATE')
   argp.add_argument('-c', '--critical', metavar='RATE', default=10,
                     help='return critical if failure percentage is higher than RATE')
   argp.add_argument('-W', '--WARNING', metavar='SECONDS', default=2,
                     help='return warning if flight time is higher than SECONDS')
   argp.add_argument('-C', '--CRITICAL', metavar='SECONDS', default=4,
                     help='return critical if flight time is higher than SECONDS')
   argp.add_argument('-t', '--test', default='test_webhook_us_east_1')
   argp.add_argument('--check_window_size', default=10,
	             help='size of time window (in MINUTES) to check for test events')
   argp.add_argument('--check_window_offset', default=1,
	             help='number of MINUTES before current time to end the check window')
   argp.add_argument('--slack_update', action='store_true', default=False)
   argp.add_argument('--slack_url', metavar='SLACK URL', default=slack_default_url)
   #argp.add_argument('--slack_channel', metavar='SLACK CHANNEL NAME', default=slack_default_channel)
   argp.add_argument('-v', '--verbose', action='count', default=0)
   argp.add_argument('-d', '--debug', action='store_true', default=False)
   args = argp.parse_args()

   if args.debug:
      logging.basicConfig(level=logging.DEBUG)
   else:
      logging.basicConfig(level=logging.ERROR)


   rate_context = "%s : failure rate" % args.test
   time_context = "%s : average flight time" % args.test

   check = nagiosplugin.Check(UDH(args.test, rate_context, time_context, args.check_window_size, args.check_window_offset),
                              nagiosplugin.ScalarContext(rate_context, args.warning, args.critical),
                              MonaContext(time_context, args.WARNING, args.CRITICAL),
			      nagiosplugin.Context('events sent'),
			      nagiosplugin.Context('events recv'),
			      nagiosplugin.Context('event errors'),
			      nagiosplugin.Context('http ok rate'),
			      nagiosplugin.Context('test batchsize'),
			      nagiosplugin.Context('check window start'),
			      nagiosplugin.Context('check window end'),
			      nagiosplugin.Context('region'),
			      MonaSummary(slack_update=args.slack_update,
				          slack_url=args.slack_url))

   check.main(verbose=args.verbose)

if __name__ == '__main__':
   main()

