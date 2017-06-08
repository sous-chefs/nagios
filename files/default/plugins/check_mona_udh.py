#!/usr/bin/env python

import nagiosplugin
from nagiosplugin.state import Ok
from nagiosplugin.state import Warn
from nagiosplugin.state import Critical
from nagiosplugin.state import Unknown
from nagiosplugin.context import Context
from nagiosplugin.context import ScalarContext
from nagiosplugin.result import Result
from nagiosplugin.metric import Metric
from nagiosplugin import Check

import argparse
import logging
import re

from datetime import datetime
from dateutil.relativedelta import *

from pymongo import MongoClient
from pymongo.errors import PyMongoError

import requests
from requests.exceptions import RequestException
requests.packages.urllib3.disable_warnings()

import json

slack_default_url = 'https://hooks.slack.com/services/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'
#slack_default_channel = '#status_udh_webhook'

from datadog import initialize, api

datadog_keys = {
   'api_key' : '566aaf588c171e448cdbe840f52b56f0',
   'app_key' : '33ebcd86deb18334bacd2d68bcc9e9ceea07b90c'
}

class UDH(nagiosplugin.Resource):

   def __init__(self, mona_test_id, eventdb, start, end, target, batchsize, region, check_window_size, check_window_offset):
      self.test = mona_test_id
      self.eventdb = eventdb
      self.start = start
      self.end = end
      self.target = target
      self.batchsize = batchsize
      self.region = region
      self.cw = check_window_size
      self.cwo = check_window_offset

   def probe(self):

      events_sent = self.eventdb.find({"test_id" : self.test, "test_target" : self.target,
					    "time_sent" : {"$gte" : self.start, "$lt" : self.end }})
      events_recv = self.eventdb.find({"test_id" : self.test, "test_target" : self.target,
					    "time_sent" : {"$gte" : self.start, "$lt" : self.end },
					    "time_recv" : {"$exists" : 1}})
      event_errors = self.eventdb.find({"test_id" : self.test, "test_target" : self.target,
					     "time_sent" : {"$gte" : self.start, "$lt" : self.end },
					     "error" : {"$exists" : 1}})
      event_http_ok = self.eventdb.find({"test_id" : self.test, "test_target" : self.target,
					      "time_sent" : {"$gte" : self.start, "$lt" : self.end },
					      "uconnect_status_code" : 200})

      total_errors = event_errors.count()
      logging.debug("total_errors-%s %d" % (self.target, total_errors))

      total_sent = events_sent.count()
      logging.debug("total_sent-%s = %d" % (self.target, total_sent))

      total_recv = events_recv.count()
      logging.debug("total_recv-%s = %d" % (self.target, total_recv))

      total_http_ok = event_http_ok.count()
      logging.debug("total_http_ok-%s = %d" % (self.target, total_http_ok))

      if total_sent == 0:
	 raise Exception("no test events found for test \"%s\" with target \"%s\" during time range %s to %s" %
			 (self.test, self.target, self.start.strftime('%c'), self.end.strftime('%c')))

      if total_recv == 0:
	 raise Exception("no test events received for test \"%s\" with target \"%s\" during time range %s to %s" %
		 (self.test, self.target, self.start.strftime('%c'), self.end.strftime('%c')))

      failure_rate = 100 - (float(total_recv)/total_sent * 100)
      http_ok_rate = (float(total_http_ok)/total_sent * 100)

      elapsed = 0
      for event in events_recv:
	 delta = event['time_recv'] - event['time_sent']
	 elapsed += delta.total_seconds()

      avg_flight_time = elapsed / total_recv

      logging.debug("elapsed-%s = %d" % (self.target, elapsed))
      logging.debug("avg-%s = %f" % (self.target, avg_flight_time))

      yield Metric("failure rate (%s)" % self.target, failure_rate, uom='%')
      yield Metric("average flight time (%s)" % self.target, "%.2f" % avg_flight_time, uom='s')
      yield Metric("event errors (%s)" % self.target, total_errors)
      yield Metric("events sent (%s)" % self.target, total_sent)
      yield Metric("events recv (%s)" % self.target, total_recv)
      yield Metric("http ok rate (%s)" % self.target, http_ok_rate, uom='%') 
      yield Metric("test batchsize", self.batchsize)
      yield Metric("check window start", self.start.strftime('%c UTC'))
      yield Metric("check window end", self.end.strftime('%c UTC'))
      yield Metric("region", self.region)


class MonaContext(ScalarContext):

   def __init__(self, name, warning=None, critical=None,
                fmt_metric='{name} is {valueunit}', result_cls=Result):

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

   def __init__(self, test_id, targets, slack_update=False, slack_url='', slack_channel='', datadog=False):
      self.test_id = test_id
      self.targets = targets
      self.slack_update = slack_update
      self.slack_url = slack_url
      #self.slack_channel = slack_channel
      self.datadog = datadog
      super(MonaSummary, self).__init__()

   def __perf_format(self, perf):
      perf = str(perf)
      #r = re.compile("'.*: ")
      #m = r.match(perf)
      #perf = perf[m.end():]
      perf = perf.translate(None, "'")
      perf = perf.replace("=", " = ")
      return perf

   def __stats_verbose(self, results):
      perfs = ""
      for result in results:
	 perf = result.metric.performance()
	 if perf:
	    perfs += "%s\n" % self.__perf_format(perf)
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

   def __datadog(self, results):

      if (self.datadog):

	 try: 
	    initialize(**datadog_keys)
	     
	    metrics = []
	    for target in self.targets:
	       metrics.append({'metric' : "udh_webhook.%s.failure_rate" % self.test_id,
			       'points' : int(results['failure rate (%s)' % target].metric.value),
			       'tags' : ["region:%s" % results['region'].metric.value,
				         "target:%s" % target]})
	       metrics.append({'metric' : "udh_webhook.%s.avg_flight_time" % self.test_id,
			       'points' : float(results['average flight time (%s)' % target].metric.value),
			       'tags' : ["region:%s" % results['region'].metric.value,
				         "target:%s" % target]})
	    logging.debug("datadog metrics:  %s" % str(metrics))
	    api.Metric.send(metrics)
	 except Exception as e:
	    logging.error("error: datadog submission failed: %s" % e)


   def ok(self,results):
      self.__slack(self.Ok, results['region'].metric.value, str(results.first_significant), self.__stats_verbose(results))
      self.__datadog(results)
      return super(MonaSummary, self).ok(results)

   def problem(self,results):
      if results.most_significant_state == Critical:
	 state = self.Critical
      elif results.most_significant_state == Warn:
	 state = self.Warn
      else:
	 state = None
      if state:
	 self.__slack(state, results['region'].metric.value, str(results.first_significant), self.__stats_verbose(results))
	 self.__datadog(results)
      return super(MonaSummary, self).problem(results)

   def verbose(self, results):
      msg = "\ncheck window start time: %s\n" % results['check window start'].metric.value
      msg += "check window end time: %s\n" % results['check window end'].metric.value
      msg += "configured test batchsize: %d\n" % results['test batchsize'].metric.value
      for target in self.targets:
	 msg += "\nTarget \"%s\":\n" % target
	 msg += "   events sent during check window: %d\n" % results['events sent (%s)' % target].metric.value
	 msg += "   events recv during check window: %d\n" % results['events recv (%s)' % target].metric.value
	 msg += "   event errors during check window: %d\n" % results['event errors (%s)' % target].metric.value
	 msg += "   uconnect http ok rate: %.2f%%\n" % results['http ok rate (%s)' % target].metric.value
      return msg
      

@nagiosplugin.guarded()
def main():
   argp = argparse.ArgumentParser(description=__doc__)
   argp.add_argument('-w', '--warning', metavar='RATE', default=5, type=float,
                     help='return warning if failure percentage is higher than RATE')
   argp.add_argument('-c', '--critical', metavar='RATE', default=10, type=float,
                     help='return critical if failure percentage is higher than RATE')
   argp.add_argument('-W', '--WARNING', metavar='SECONDS', default=30, type=int,
                     help='return warning if flight time is higher than SECONDS')
   argp.add_argument('-C', '--CRITICAL', metavar='SECONDS', default=60, type=int,
                     help='return critical if flight time is higher than SECONDS')
   argp.add_argument('-t', '--test', default='test_webhook_us_east_1')
   argp.add_argument('--check_window_size', default=10, type=int,
	             help='size of time window (in MINUTES) to check for test events')
   argp.add_argument('--check_window_offset', default=1, type=int,
	             help='number of MINUTES before current time to end the check window')
   argp.add_argument('--slack_update', action='store_true', default=False,
	             help='enable Slack-channel updates')
   argp.add_argument('--slack_url', metavar='SLACK URL', default=slack_default_url)
   #argp.add_argument('--slack_channel', metavar='SLACK CHANNEL NAME', default=slack_default_channel)
   argp.add_argument('--datadog_update', action='store_true', default=False,
	             help='enable Datadog metric submissions')
   argp.add_argument('-v', '--verbose', action='count', default=0)
   argp.add_argument('-d', '--debug', action='store_true', default=False)
   args = argp.parse_args()

   if args.debug:
      logging.basicConfig(level=logging.DEBUG)
   else:
      logging.basicConfig(level=logging.ERROR)

   mongo = MongoClient('mongos-cluster-1.prod1.us-w1.int.ops.tlium.com',27017)
   cfgdb = mongo['ops']['mona_config']
   eventdb = mongo['ops']['mona_events']

   cfg = cfgdb.find_one({"_id" : args.test})

   if not cfg:
      raise Exception("unknown test identifier: %s" % args.test)

   if 'region' in cfg:
      region = cfg['region']
   else:
      region = 'Yonder'

   if 'batchsize' in cfg:
      batchsize = cfg['batchsize']
   else:
      batchsize = 'N/A'

   end = datetime.utcnow()
   end = end - relativedelta(minutes=args.check_window_offset)
   start = end - relativedelta(minutes=args.check_window_size)

   logging.debug("start time: %s" % start)
   logging.debug("end time: %s" % end)

   check = nagiosplugin.Check()

   for target in cfg['targets']:

      udh = UDH(args.test, eventdb, start, end, target, batchsize, region, args.check_window_size, args.check_window_offset)

      check.add(udh)
      check.add(ScalarContext("failure rate (%s)" % target, args.warning, args.critical),
		MonaContext("average flight time (%s)" % target, args.WARNING, args.CRITICAL),
		Context("events sent (%s)" % target),
		Context("events recv (%s)" % target),
		Context("event errors (%s)" % target),
		Context("http ok rate (%s)" % target))

   check.add(Context("test batchsize"),
	     Context("check window start"),
	     Context("check window end"),
	     Context("region"),
	     MonaSummary(args.test, targets=cfg['targets'],
		         slack_update=args.slack_update,
			 slack_url=args.slack_url,
			 datadog=args.datadog_update))

   check.main(verbose=args.verbose)

if __name__ == '__main__':
   main()

