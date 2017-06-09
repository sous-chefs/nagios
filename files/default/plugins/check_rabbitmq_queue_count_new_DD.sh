#!/bin/bash

#$1 = rabbitmq url
#$2 = vhost
#$3 = user
#$4 = pass
#$5 = region
#$6 = queue
#$7 = count 
#$8 = port

tmp_file=/tmp/queues-$5-$6-DD.json

curl -i -u $3:$4 http://$1:$8/api/queues/%2fserver2server | tail -n+9 > $tmp_file

python /usr/lib/nagios/plugins/check_rabbitmq_queue_count.py /tmp/queues-$5-$6-DD.json 2> /tmp/count-$5-$6-DD.log

queue_count=`cat $tmp_file | grep $6 | wc -l`

if (($queue_count < $7)); then
  echo $6 "queue_count is" $queue_count". It should be at greater than or equal to" $7
  exit 2
fi

echo "OK - $6 queue_count is ${queue_count}.  It is greater than or equal to $7"
exit 0
