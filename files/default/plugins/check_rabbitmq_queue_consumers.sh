#!/bin/bash

tmp_file=/tmp/consumers-$5-$6.json

curl -i -u $3:$4 http://$1:15672/api/queues/%2fserver2server/$6 | tail -n+9 > $tmp_file

if [[ ! -s $tmp_file ]]; then 
# echo "0 byte file."
  #echo "Not OKT - Failed! Consumer count is 0 should be" $7"."
  echo "Not OK - Problem with partition" $7"."
  exit 2 ; 
fi

python  /usr/lib/nagios/plugins/check_rabbitmq_queue_consumers.py $tmp_file 2> /tmp/consumer_count-$5-$6.log

consumer_count=`cat $tmp_file`
if [ $consumer_count != $7 ]
then
#  echo "Value should be" $7
  echo "Not OK - Failed! Consumer count is" $consumer_count ", it should be" $7 "for queue" $6"."
  exit 2
else
#  echo "Value should be" $7 "and is correct."
  echo "OK - Consumer count is" $consumer_count
fi
exit
