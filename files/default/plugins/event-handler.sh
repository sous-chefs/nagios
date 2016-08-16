#!/bin/bash

# $1 is $SERVICESTATE$ (OK WARNING UNKNOWN CRITICAL) 
# $2 is $SERVICESTATETYPE$ (SOFT HARD) 
# $3 is $SERVICEATTEMPT$ (1 through 4)
# $4 is region
date=`date`

case "$1" in 
OK)

"In OK State-" $date >>/tmp/event_handler.log 2&>1
	;;
WARNING)

"In Warning State-" $date >>/tmp/event_handler.log 2&>1
	;;
UNKNOWN)

"In Unknown State-" $date >>/tmp/event_handler.log 2&>1
	;;
CRITICAL)
        date=`date` 2> /tmp/event_handler.log 
        echo "In Critical State-" $date >>/tmp/event_handler.log 2&>1
	case "$2" in
	SOFT)
		case "$3" in
		1)
                   # 1st notification, usually watch for a 2nd. 
                   echo "Critical SOFT 1st pass-" $date >>/tmp/event_handler.log  2&>1
			;;
		2)
                   # 2nd notification, try to fix with a script
                   echo "Critical SOFT 2nd pass-" $date >>/tmp/event_handler.log  2&>1
                   echo ""
                   # This where we want to do the work
                   queue=`cat /tmp/failed_queue.log` >>/tmp/event_handler.log 2&>1
                   echo "Bad consumer count for queue, called by event handler at "$date" querying Mongo for offending VP IP of" $queue >>/tmp/event_handler.log 2>&1
 
#                   region=$4
#                   echo "Region (Fourth argument) is" $region >>/tmp/event_handler.log 2>&1
#                   IP=`/usr/lib/nagios/plugins/mongo_lookup.sh $queue $region` >>/tmp/event_handler.log 2>&1

#                   output=`mongo 10.1.2.130:27017/datacloud_cluster_state < db.datacloudcluster_servers.find({"node_type":"VISITOR_PROCESSOR","region":"eu-central-1","status":"ACTIVE",$and:[{"partition_range_start":{$queue:74}},{"partition_range_end":{$gte:$queue}}]},{_id:0,node_host:1}).pretty()`
#                   output=`mongo 10.1.2.130:27017 < /usr/lib/nagios/plugins/mongo_call.js
#                   echo $output | cut -d '"' -f4 >>/tmp/event_handler.log 2>&1
                   #echo "%s/$queue/num/g
                   #w
                   #q
                   #" | ex /usr/lib/nagios/plugins/mongo_call.js
 #                  echo "Mongo provided this IP: "$IP "-" $date >>/tmp/event_handler.log 2>&1
                   #SSH to the instance to restart the VP process
                    echo "Using SED to change num to"$queue >>/tmp/event_handler.log 2>&1
                    sed -i "s/number/$queue/g" /tmp/mongo_call.js 2>>/tmp/event_handler.log 
                    sed -i "s/number/$queue/g" /usr/lib/nagios/plugins/mongo_call.js >>/tmp/event_handler.log 2>&1
                    echo "SED call made" >>/tmp/event_handler.log 2>&1
#
                    echo "Using SED to change region to "$4 >>/tmp/event_handler.log 2>&1
                    sed -i "s/where/$4/g" /tmp/mongo_call.js 2>/tmp/event_handler.log
                    echo "SED call made" >>/tmp/event_handler.log 2>&1

                    output=`mongo host-"10.1.2.130:27017" datacloud_cluster_state < mongo_call.js` 2> /tmp/event_handler.log
                    echo $output | cut -d '"' -f4 >>/tmp/event_handler.log 2>
                    IP=`echo $output | cut -d '"' -f4` 2>
                    echo "IP is "$IP 2>
                    echo "Mongo provided this IP: "$IP "-" $date >>/tmp/event_handler.log 2>&1
                    ssh -oStrictHostKeyChecking=no -i /etc/nagios3/conf.d/devops_id_rsa.pem -oUserKnownHostsFile=/dev/null devops@$IP 'sudo initctl stop datacloud-visitor_processor; sudo initctl start datacloud-visitor_processor; sudo service splunk stop; sudo service splunk start' >>/tmp/event_handler.log 2>&1
			;;
		3)
		   # Script must have failed, try a 2nd script or send out email notifications.
                   echo "Critical SOFT 3rd pass-" $date >> /tmp/event_handler.log
			;;
		esac
			;;
	HARD)
		case "$3" in
		1)
                   # 1st notification, usually watch for a 2nd. 
                   echo "Critical HARD 1st pass-" $date >> /tmp/event_handler.log
			;;
		2)
                   # 2nd notification, try to fix with a script
                   # This where we want to do the work
                   echo "Critical HARD 2nd pass-" $date >> /tmp/event_handler.log
                   # Calling the same script that failed to call this Event Handeler  
                   echo "Calling Rabbit script from HARD" $date >> /tmp/event_handler.log
                   /usr/lib/nagios/plugins/check_rabbitmq_queue_consumers_multi.sh $4 $5 $6 $7 $8 ${10} ${10} ${11} ${12}
                   echo "Called Rabbit script from HARD" $date >> /tmp/event_handler.log
                   #/usr/lib/nagios/plugins/check_rabbitmq_queue_consumers_multi_test.sh $4 $5 $6 $7 $8 $9 ${10} ${11}
                   #echo "Critical HARD 2nd pass-" $date >> /tmp/event_handler.log
			;;
		3)
		   # Script must have failed, try a 2nd script or send out email notifications.
i                  echo "Critical HARD 3rd pass-" $date >> /tmp/event_handler.log
			;;
	        esac
			;;
	esac
	;;
esac
exit 0
