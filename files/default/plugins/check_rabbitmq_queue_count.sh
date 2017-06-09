#!/bin/bash

#$1 = rabbitmq url
#$2 = vhost
#$3 = user
#$4 = pass
#$5 = region
#$6 = port

tmp_file=/tmp/queues-$5.json

curl -i -u $3:$4 http://$1:$6/api/queues/%2fserver2server | tail -n+9 > $tmp_file

python /usr/lib/nagios/plugins/check_rabbitmq_queue_count.py /tmp/queues-$5.json 2> /tmp/count-$5.log

mr_to_vp_queue_count=`cat $tmp_file | grep mr_to_vp | wc -l`

vp_to_qp_queue_count=`cat $tmp_file | grep vp_to_qp | wc -l`

vp_to_vp_queue_count=`cat $tmp_file | grep vp_to_vp_ | wc -l`

echo " mr_to_vp_queue_count is $mr_to_vp_queue_count"
echo " vp_to_qp_queue_count is $vp_to_qp_queue_count"
echo " vp_to_vp_queue_count is $vp_to_vp_queue_count"

if (($mr_to_vp_queue_count < 100)); then
  exit 2
elif (($vp_to_qp_queue_count < 100)); then
  exit 2
elif (($vp_to_vp_queue_count < 100)); then
  exit 2
fi

echo "OK - queue count is correct for $6 queues."
exit 0
