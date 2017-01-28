#!/bin/bash

tmp_file=/tmp/$5-$6.log

curl -i -u $3:$4 http://$1:15672/api/exchanges/%2fserver2server/$6 | tail -n+9 | grep -ow "channel_details" | wc -l > $tmp_file

count=`cat $tmp_file`

if [[ "$count" != "$7" ]]; then
  echo $6 "exchange channel count is" $count". It should be equal to" $7
  exit 2
fi

echo "OK - "$6 "exchange count is" $count". It should be equal to" $7
exit
