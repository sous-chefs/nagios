#!/bin/bash 

jmx_rate="$(/usr/lib/nagios/plugins/check_jmx -U service:jmx:rmi:///jndi/rmi://$1:9001/jmxrmi -O "DataCloud-Metrics:name=VisitorProcessor-TotalEventsIgnoredDueToMaxVisitorsLimit" -A FiveMinuteRate)"
#echo $rate
cut_rate="$(cut -d "=" -f 2 <<< "$jmx_rate")"
#echo $cut_rate
trim_rate="${cut_rate%%|*}"
#echo "pre-fix rate: " $trim_rate
format_rate="$(printf "%.5f\n" $trim_rate)"
#echo "post-fix rate: "$format_rate
max=1
#echo $max
if (( $(echo "$format_rate >= $max" | bc -l) )); then
  echo "Failure: Events ignored is more than 1. Initial: " $trim_rate " Formatted: " $format_rate 
  exit 1
else
  echo "Success: Events ignored is less than 1. Initial: " $trim_rate " Formatted: " $format_rate
  exit 0
fi
