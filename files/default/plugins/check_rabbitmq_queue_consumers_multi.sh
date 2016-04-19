#!/bin/bash

i=0
tmp_file2=/tmp/testfilelog.log

while [ $i -le $8 ]; do
  queue=$6_$i

  tmp_file=/tmp/consumers-$5-$queue.json

  curl -i -u $3:$4 http://$1:15672/api/queues/%2fserver2server/$queue | tail -n+9 > $tmp_file

  if [[ ! -s $tmp_file ]]; then
    echo "Not OK - Problem with queue" $queue"."
    exit 2 ;
  fi

  python  /usr/lib/nagios/plugins/check_rabbitmq_queue_consumers.py $tmp_file 2> /tmp/consumer_count-$5-$queue.log

  consumer_count=`cat $tmp_file`
  if [ $consumer_count != $7 ]; then
    echo "Not OK - Failed! Consumer count is" $consumer_count ", it should be" $7 "for queue" $queue"."
    exit 2
  fi

  i=$(($i +1 ))
done

echo "OK - All" $6 "queues have" $7 "consumer/s."
exit
