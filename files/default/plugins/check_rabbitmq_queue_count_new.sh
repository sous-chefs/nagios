#!/bin/bash

tmp_file=/tmp/queues-$5.json

curl -i -u $3:$4 http://$1:15672/api/queues/%2fserver2server | tail -n+9 > $tmp_file

python /usr/lib/nagios/plugins/check_rabbitmq_queue_count.py /tmp/queues-$5.json 2> /tmp/count-$5.log

queue_count=`cat $tmp_file | grep $6 | wc -l`

echo $6 "queue_count is" $queue_count". It should be at greater than or equal to" $7

if (($queue_count < $7)); then
  echo $6 "queue_count is" $queue_count". It should be at greater than or equal to" $7
  exit 2
fi

exit
