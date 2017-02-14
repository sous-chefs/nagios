#!/bin/bash 

# $1 $SERVICESTATE$ (OK WARNING UNKNOWN CRITICAL) 
# $2 $SERVICESTATETYPE$ (SOFT HARD) 
# $3 $SERVICEATTEMPT$ (1 through 4)
# $4 region
# $5 mongo_ip 
# $6 queue_name

date=`date`
log=/tmp/vp_handler.log
js_file=/tmp/mongo_call.js

case "$1" in
OK)

        echo $date " In OK State." >> $log
        echo ""
        ;;
WARNING)

        echo $date " In Warning State." >> $log
        ;;
UNKNOWN)

        ;;
CRITICAL)
        echo $date " In Critical State." >> $log
        case "$2" in
        SOFT)
                case "$3" in
                1)
                   # 1st notification, usually watch for a 2nd. 
                   #echo $date " Critical SOFT 1st pass." >> $log
                   #clean up
                   rm -rf $js_file

                   # This where we want to do the work
                   queue=$( cat /tmp/failed_queue.log )
                   echo $date " Bad consumer count in RabbitMQ for queue" $6"_"$queue" in region" $4". Querying MongoDB for the IP of the VP subscribed to queue" $6"_"$queue" in region" $4"." >> $log

                   echo $date " Attempting MongoDB query creation." >> $log

                   echo "db.datacloudcluster_servers.find({\"node_type\":\"VISITOR_PROCESSOR\",\"region\":\"$4\",\$and:[{\"partition_range_start\":{\$lte:$queue}},{\"partition_range_end\":{\$gte:$queue}}]},{_id:0,node_host:1}).pretty()" > $js_file

                   echo $date " MongoDB query is:" `cat $js_file` >> $log

                   IP=`mongo --quiet $5:27017/datacloud_cluster_state < $js_file | cut -d '"' -f4`

                   echo $date " Mongo provided this IP: "$IP", for " $6"_"$queue " in" $4"." >> $log
                   echo $date " Issuing remote restart command to "$IP"." >> $log

                   ssh -oStrictHostKeyChecking=no -i /etc/nagios3/conf.d/devops_id_rsa.pem -oUserKnownHostsFile=/dev/null devops@$IP 'sudo initctl stop datacloud-visitor_processor; sudo initctl start datacloud-visitor_processor'

                   echo $date " VP Service restarted on "$IP"." >> $log
                   echo "" >> $log
                   echo "" >> $log

                   #send an email to tell us about it
                   sender=devops@tealium.com
                   emailfile=/tmp/myemail.email
                   ltlt="<"
                   gtgt=">"

                   echo "Subject: Automated VP Restart $date" > $emailfile
                   echo "From: $sender  $ltlt$sender$gtgt" >> $emailfile
                   echo "To: $sender  $ltlt$sender$gtgt" >> $emailfile
                   echo "" >> $emailfile
                   echo "$date" >> $emailfile
                   echo "$(tail -n 8 /tmp/vp_handler.log)" >> $emailfile

                   cat $emailfile | nullmailer-inject -h
                        ;;
                2)
                   # 2nd notification, try to fix with a script
                   echo $date " Critical SOFT 2nd pass." >> $log
                        ;;
                3)
                   # Script must have failed, try a 2nd script or send out email notifications.
                   echo $date " Critical SOFT 3rd pass" >> $log
                        ;;
                esac
                        ;;
        HARD)
                case "$3" in
                1)
                   # 1st notification, usually watch for a 2nd. 
                   echo $date " Critical HARD 1st pass" >> $log
                        ;;
                2)
                   # 2nd notification, try to fix with a script
                   echo $date " Critical HARD 2nd pass" >> $log
                        ;;
                3)
                   # Script must have failed, try a 2nd script or send out email notifications.
                   echo $date " Critical HARD 3rd pass" >> $log
                        ;;
                esac
                        ;;
        esac
        ;;
esac
exit 0
