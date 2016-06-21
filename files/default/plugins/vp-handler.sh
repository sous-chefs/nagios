#!/bin/bash

# $1 is $SERVICESTATE$ (OK WARNING UNKNOWN CRITICAL) 
# $2 is $SERVICESTATETYPE$ (SOFT HARD) 
# $3 is $SERVICEATTEMPT$ (1 through 4)
# $4 is region
date=`date`

case "$1" in 
OK)

        echo $date "- In OK State." >>/tmp/vp_handler.log
        echo ""
	;;
WARNING)

#"In Warning State-" $date >>/tmp/event_handler.log 2&>1
        echo $date "- In Warning State." >>/tmp/vp_handler.log
	;;
UNKNOWN)

#echo $date "In Unknown State." >>/tmp/vp_handler.log
	;;
CRITICAL)
        echo $date "- In Critical State." >>/tmp/vp_handler.log
	case "$2" in
	SOFT)
		case "$3" in
		1)
                   # 1st notification, usually watch for a 2nd. 
                   echo $date "- Critical SOFT 1st pass." >>/tmp/vp_handler.log
			;;
		2)
                   # 2nd notification, try to fix with a script
                   echo $date "- Critical SOFT 2nd pass." >>/tmp/vp_handler.log

                   # This where we want to do the work
                   queue=`cat /tmp/failed_queue.log`
                   echo $date "- Bad consumer count for queue" $queue". Querying Mongo for offending VP IP of queue" $queue"." >>/tmp/vp_handler.log
 

                    echo $date "- Attempting MonogDB query creation" >> /tmp/vp_handler.log

                    sed -i -e 's/'"number"'/'"$queue"'/g' /usr/lib/nagios/plugins/mongo_call.js
                    sed -i -e 's/'"where"'/'"$4"'/g' /usr/lib/nagios/plugins/mongo_call.js

                    echo "MongoDB query is:" >>/tmp/vp_handler.log
                    echo `cat /usr/lib/nagios/plugins/mongo_call.js` >>/tmp/vp_handler.log
                    echo $date "- Querying MongoDB for the IP of the VP related to" $queue"." >>/tmp/vp_handler.log
                   #mongo 10.1.2.130:27017/datacloud_cluster_state < db.datacloudcluster_servers.find({"node_type":"VISITOR_PROCESSOR","region":\""$4\"","status":"ACTIVE",$and:[{"partition_range_start":{$lte:$queue}},{"partition_range_end":{$gte:$queue}}]},{_id:0,node_host:1}).pretty() > /tmp/vp_mongo.log
                   output=`mongo 10.1.2.130:27017 < /usr/lib/nagios/plugins/mongo_call.js`
                   IP=`echo $output | cut -d '"' -f4`

                     echo $date "- Mongo provided this IP: "$IP >>/tmp/vp_handler.log
 
                     ssh -oStrictHostKeyChecking=no -i /etc/nagios3/conf.d/devops_id_rsa.pem -oUserKnownHostsFile=/dev/null devops@$IP 'sudo initctl stop datacloud-visitor_processor; sudo initctl start datacloud-visitor_processor; sudo service splunk stop; sudo service splunk start' >>/tmp/vp_handler.log

                      sed -i -e 's/'"$queue"'/'"number"'/g' /usr/lib/nagios/plugins/mongo_call.js
                      sed -i -e 's/'"$4"'/'"where"'/g' /usr/lib/nagios/plugins/mongo_call.js
                      echo "Reset mongoDB query is:" >>/tmp/vp_handler.log
                      echo `cat /usr/lib/nagios/plugins/mongo_call.js` >>/tmp/vp_handler.log
                      echo $date "- VP Service restarted on "$IP"." >>/tmp/vp_handler.log
			;;
		3)
		   # Script must have failed, try a 2nd script or send out email notifications.
                   echo "Critical SOFT 3rd pass-" $date >> /tmp/vp_handler.log
			;;
		esac
			;;
	HARD)
		case "$3" in
		1)
                   # 1st notification, usually watch for a 2nd. 
                   echo "Critical HARD 1st pass-" $date >> /tmp/vp_handler.log
			;;
		2)
                   # 2nd notification, try to fix with a script
                   echo "Critical HARD 2nd pass-" $date >> /tmp/vp_handler.log
			;;
		3)
		   # Script must have failed, try a 2nd script or send out email notifications.
i                  echo "Critical HARD 3rd pass-" $date >> /tmp/vp_handler.log
			;;
	        esac
			;;
	esac
	;;
esac
exit 0
