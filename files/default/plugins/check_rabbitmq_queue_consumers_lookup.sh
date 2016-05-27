#!/bin/bash -x

#$1 = rabbitmq url
#$2 = vhost
#$3 = user
#$4 = pass
#$5 = region
#$6 = queue
#$7 = count
#$8 = id array

array=$8

for i in ${array[@]}; do

#echo "Checking instance" ${i}
tmp_file=/tmp/consumers-$5-$6$i.json

queue=$6$i
#echo $queue
curl -i -u $3:$4 http://$1:15672/api/queues/%2fserver2server/$queue | tail -n+9 > $tmp_file

if [[ ! -s $tmp_file ]]; then
  echo "Not OK - Error, 0 byte or unaccessable tmp_file at /tmp/consumers-"$5-$6"$i.json"
  exit 2 ;
fi

python  /usr/lib/nagios/plugins/check_rabbitmq_queue_consumers.py $tmp_file 2> /tmp/consumer_count-$5-$6$i.log

consumer_count=`cat $tmp_file`
#echo $consumer_count
if [ $consumer_count != $7 ]
then
  echo "Not OK - Failed! Consumer count is" $consumer_count ", it should be" $7 "for queue" $6"."
  exit 2
#else
#  echo "Consumer count is:" ${consumer_count}
fi
done
echo "OK - Consumer count is correct for" $5 $6 "queues."
exit 0
