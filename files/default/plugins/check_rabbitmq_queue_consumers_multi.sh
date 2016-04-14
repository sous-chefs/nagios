#!/bin/bash

#for i in {0..$8}; do
i=0
tmp_file2=/tmp/testfilelog.log
#echo "Initiating -"`date` >> $tmp_file2
while [ $i -le $8 ]; do
  queue=$6_$i
 # echo "Queue name is " $queue "." 
 # echo "Queue name is " $queue "." >> $tmp_file2

  tmp_file=/tmp/consumers-$5-$queue.json

  curl -i -u $3:$4 http://$1:15672/api/queues/%2fserver2server/$queue | tail -n+9 > $tmp_file

  if [[ ! -s $tmp_file ]]; then
  # echo "0 byte file."
    #echo "Not OKT - Failed! Consumer count is 0 should be" $7"."
    echo "Not OK - Problem with partition" $7"."
    exit 2 ;
  fi

  python  /usr/lib/nagios/plugins/check_rabbitmq_queue_consumers.py $tmp_file 2> /tmp/consumer_count-$5-$queue.log

  consumer_count=`cat $tmp_file`
  if [ $consumer_count != $7 ]; then
    #echo "Value should be" $7
    echo "Not OK - Failed! Consumer count is" $consumer_count ", it should be" $7 "for queue" $queue"."
    exit 2
#  else
#    #echo "OK - Consumer count is" $consumer_count "for queue" $queue"."
#    echo "OK - All" $6 "queues have" $7 "consumer."
#    exit
  fi

  #/usr/lib/nagios/plugins/check_rabbitmq_queue_consumers.sh $1 $2 $3 $4 $5 $queue $7
  #result=`echo $?`
  #if [ $result -eq 0 ]; then
  #  echo "Success from sub-check."
  #else 
  #  echo "Not OK - Failed! The queue" $queue "has no consumer."
  #  exit 2
  #fi

  i=$(($i +1 ))
done

echo "OK - All" $6 "queues have" $7 "consumer."
exit
