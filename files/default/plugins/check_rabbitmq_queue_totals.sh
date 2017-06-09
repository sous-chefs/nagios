#!/bin/bash -x

#$1 = rabbitmq url
#$2 = user
#$3 = pass
#$4 = count
#$5 = region
#$6 = port

tmp_file=/tmp/queue-totals-$5.json
curl -i -u $2:$3 http://$1:$6/api/overview | tail -n+9 > $tmp_file

if [[ ! -s $tmp_file ]]; then
  echo "Not OK - Error, 0 byte or unaccessable tmp_file at /tmp/queue-totals.json"
  exit 2 ;
fi

python  /usr/lib/nagios/plugins/check_rabbitmq_queue_totals.py $tmp_file 2> /tmp/queue-totals-$5.log

queue_count=`cat $tmp_file`
if [ $queue_count -ge $4 ]
then
  echo "Not OK - Failed! Total Queue count is" $queue_count ", it should be less than " $4 "."
  exit 2
fi
echo "OK - Queue count is" $queue_count "for all queues."
exit 0
