#!/usr/bin/env python

desc = """
Checks the status of the most recent MongoDB backup or, with the --snap option,
checks that the snapshots for the most recent backup were completed.
"""

import kazoo
from kazoo.client import KazooClient
from kazoo.client import KazooState
import yaml
import argparse
import time
from datetime import datetime
from datetime import timedelta

class Status(dict):

   def __init__(self, name, code, msg):
      self.name = name
      self.code = code
      self.msg = msg

   def exit(self):

      print "%s - %s" % (self.name, self.msg)
      raise SystemExit(self.code)


class OK(Status):

   def __init__(self,msg):
      super(OK,self).__init__('OK', 0, msg)


class WARNING(Status):

   def __init__(self,msg):
      super(WARNING,self).__init__('WARNING', 1, msg)


class CRITICAL(Status):

   def __init__(self,msg):
      super(CRITICAL,self).__init__('CRITICAL', 2, msg)


class UNKNOWN(Status):

   def __init__(self,msg):
      super(UNKNOWN,self).__init__('UNKNOWN', 3, msg)


def state_listener(state):
   if state == KazooState.LOST:
      error("zookeeper connection state was lost")
   elif state == KazooState.SUSPENDED:
      error("zookeeper connection state was suspended")
   elif state == KazooState.CONNECTED:
      pass


def create_date_path(days_ago):
   when = datetime.utcnow()
   if days_ago:
      delta = timedelta(days=days_ago)
      when = when - delta
   return when.strftime("/%Y/%m/%d")


def look4abort(zk, days_ago=None):

   day_node = args.prefix.rstrip('/') + '/' + args.env.rstrip('/') + create_date_path(days_ago) 

   if zk.exists(day_node):
      hours = zk.retry(zk.get_children, day_node)
      if len(hours):
	 hours.sort()
	 abort_node = day_node + '/' + str(hours[-1]) + '/ABORT'
	 if zk.exists(abort_node):
	    excuse = zk.retry(zk.get, abort_node)
	    return CRITICAL("found backup abort status: %s" % excuse[0])
	 else:
            return OK('no abort during most recent backup')
      else:
         # Apparently no backups yet today.  Let's check yesterday.

         # Let's not explore infinity though...
         if days_ago: return WARNING('found no backup info for past two days')

         return look4abort(zk, 1)

   else:

      # Apparently no backups yet today.  Let's check yesterday.

      # Let's not explore infinity though...
      if days_ago: return WARNING('found no backup info for past two days')

      return look4abort(zk, 1)


def look4snaps(zk, days_ago=None):

   import boto
   import boto.ec2
   import boto.utils
   import chef

   instance_id = boto.utils.get_instance_metadata()['instance-id']

   if args.region:
      region_spec = args.region
   else:
      region_spec = boto.utils.get_instance_identity()['document']['region']

   chef_api = chef.autoconfigure()

   node = chef.Node(instance_id)
   my_app_env = node.attributes['app_environment']

   bag = chef.DataBag('aws')
   item = bag[my_app_env]
   key_id = str(item['aws_access_key_id'])
   key_secret = str(item['aws_secret_access_key'])

   region = boto.ec2.get_region(region_spec, aws_access_key_id=key_id, aws_secret_access_key=key_secret)

   conn = region.connect(aws_access_key_id=key_id, aws_secret_access_key=key_secret)

   day_node = args.prefix.rstrip('/') + '/' + args.env.rstrip('/') + create_date_path(days_ago) 

   if zk.exists(day_node):
      hours = zk.retry(zk.get_children, day_node)
      if len(hours):
	 hours.sort()
	 shards_parent_node = day_node + '/' + str(hours[-1]) + '/mongodb_shard_server'
	 if zk.exists(shards_parent_node):

            shard_list = zk.retry(zk.get_children, shards_parent_node)
            if len(shard_list) == 0:
               return CRITICAL("mongodb shard data not available for most recent backup")

            msg = ''
            err = 0
            for shard in shard_list:
               shard_data = zk.retry(zk.get, shards_parent_node + '/' + shard)
               snaps = conn.get_all_snapshots(eval(shard_data[0]))

               msg = msg + ", %s [" % shard
               snap_text = ''
               for snap in snaps:

                  if snap.status == 'error': err = 1

                  snap_text = snap_text + ", %s (%s)" % (str(snap), snap.status)

               msg = msg + snap_text.strip(', ') + ']'

            if err:
	       return CRITICAL(msg.strip(', '))

            return OK(msg.strip(', '))

	 else:
	    return CRITICAL("mongodb shard data not available for most recent backup")

      else:
         # Apparently no backups yet today.  Let's check yesterday.

         # Let's not explore infinity though...
         if days_ago: return WARNING('found no backup info for past two days')

         return look4snaps(zk, 1)

   else:

      # Apparently no backups yet today.  Let's check yesterday.

      # Let's not explore infinity though...
      if days_ago: return WARNING('found no backup info for past two days')

      return look4snaps(zk, 1)


if __name__ == '__main__':

   gargle = argparse.ArgumentParser(prog = "check_mongodb_backup", description=desc,
	       usage='%(prog)s [options]',
	       formatter_class = argparse.RawDescriptionHelpFormatter)

   gargle.add_argument('--prefix', dest="prefix", metavar="<path_prefix>", default='/backup/mongodb_cluster/',
                       help='ZooKeeper path prefix (default: /backup/mongodb_cluster/)')

   gargle.add_argument('--cluster', dest="env", metavar="<cluster_id>", default='production',
                       help='MongoDB cluster name (default: production)')

   gargle.add_argument('--config', dest='yaml', metavar="<config_file>",
		      help='ZooKeeper server list file (default: /etc/zookeeper/server_list.yml)',
                      default='/etc/zookeeper/server_list.yml')

   gargle.add_argument('--region', metavar="<aws-region-spec>",
		      help='AWS region where the snapshots are stored (default: region of host instance)')

   gargle.add_argument('--snaps', action='store_true',
		      help='check snapshots from most recent backup (default: False)')

   args = gargle.parse_args()

   try:
      y = yaml.safe_load(open(args.yaml))
      servers = ','.join("%s:%s" % (s['host'],s['port']) for s in y['zookeepers'])


      zk = KazooClient(hosts=servers)
      zk.start()
      zk.add_listener(state_listener)

      if args.snaps:
         status = look4snaps(zk)
      else:
         status = look4abort(zk)

      zk.remove_listener(state_listener)
      zk.stop()

      status.exit()

   except Exception as e:
      UNKNOWN("Error: %s" % e).exit()

