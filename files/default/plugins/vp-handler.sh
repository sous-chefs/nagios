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

        echo $date "- In Warning State." >>/tmp/vp_handler.log
        ;;
UNKNOWN)

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

                   #clean up
                   rm -rf /tmp/mongo_call.js

                   # This where we want to do the work
                   queue=$( cat /tmp/failed_queue.log )
                   echo $date "- User ID is:" $UID >> /tmp/vp_handler.log
                   echo $date "- Bad consumer count for queue" $queue" in region" $4". Querying Mongo for offending VP IP of queue" $queue" in region" $4"." >> /tmp/vp_handler.log

                   echo $date "- Attempting MonogDB query creation" >> /tmp/vp_handler.log
                   echo "" >> /tmp/vp_handler.log

                   echo "db.datacloudcluster_servers.find({\"node_type\":\"VISITOR_PROCESSOR\",\"region\":\"$4\",\$and:[{\"partition_range_start\":{\$lte:$queue}},{\"partition_range_end\":{\$gte:$queue}}]},{_id:0,node_host:1}).pretty()" > /tmp/mongo_call.js

                   echo $date "- MongoDB query is:" >>/tmp/vp_handler.log
                   echo "" >> /tmp/vp_handler.log
                   echo `cat /tmp/mongo_call.js` >>/tmp/vp_handler.log
                   query=`cat /tmp/mongo_call.js`
                   echo "" >> /tmp/vp_handler.log
                   echo $date "- Querying MongoDB for the IP of the VP related to queue" $queue" in region" $4"." >> /tmp/vp_handler.log
                   echo "" >> /tmp/vp_handler.log

                   IP=`mongo --quiet 10.1.2.130:27017/datacloud_cluster_state < /tmp/mongo_call.js | cut -d '"' -f4`

                   echo $date "- Mongo provided this IP: "$IP >> /tmp/vp_handler.log

                   ssh -oStrictHostKeyChecking=no -i /etc/nagios3/conf.d/devops_id_rsa.pem -oUserKnownHostsFile=/dev/null devops@$IP 'sudo initctl stop datacloud-visitor_processor; sudo initctl start datacloud-visitor_processor' >> /tmp/vp_handler.log

                    echo $date "- VP Service restarted on "$IP"." >> /tmp/vp_handler.log
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
                   echo "Critical HARD 3rd pass-" $date >> /tmp/vp_handler.log
                        ;;
                esac
                        ;;
        esac
        ;;
esac
exit 0
