#!/usr/bin/ruby

require_relative './rabbitmq'
require 'getoptlong'
require 'pp'

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--username', '-u', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--password', '-p', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--url', '-r', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--threshold', '-t', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--list_queues', '-l', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--report_vp_cluster_status', '-s', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--purge_queue', '-q', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--queue_info', '-i', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--vhost', '-v', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--name', '-n', GetoptLong::OPTIONAL_ARGUMENT ]
)

url = 'https://my.tealiumiq.com/urest'
username = nil
password = nil
command = nil
vhost = nil
name = nil
threshold = 1

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
hello [OPTION] ... DIR

-h, --help:
   show help
   OPTIONAL

--username, -u:
   rabbitmq admin user
   REQUIRED

--password, -p:
   rabbitmq admin password
   REQUIRED

--url, -r:
   url of the Rabbitmq API endpoint
   OPTIONAL

--threshold, -t:
   filter response (e.g. what queues to return) that have ready 
   messages above this number.  E.g. return queues above 1000 
   messages... Default is 1.  Queues not empty.
   OPTIONAL

--list_queues, -l:
   get a list of the queues on the rabbitmq server
   OPTIONAL

--purge_queue, -q
   purge an individual queue within a vhost.  Requires vhost and queue_name.
   OPTIONAL

--vhost, -v
   vhost name
   OPTIONAL

--name, -n
   queue name in the vhost
   OPTIONAL

--queue_info, -i
   get a hash returned with all the info about the queue
   OPTIONAL

Example commands:

To list all queues:
ruby rabbitmq_admin.rb -u admin -p adminpass -r http://us-east-1.cluster.rabbitmq.tealiumiq.com --list_queues

Purge a queue by vhost and name:
ruby rabbitmq_admin.rb -u admin -p adminpass -r http://us-east-1.cluster.rabbitmq.tealiumiq.com --purge_queue -v vhost -n pueue_name

Get info on a specific vhost/queue
ruby rabbitmq_admin.rb -u admin -p adminpass -r http://us-east-1.cluster.rabbitmq.tealiumiq.com -i -v server2server -n vp_to_au_expiredvisitor_queue


  EOF
  exit 0

  when '--list_queues'
    command = "list_queues"
  when '--purge_queue'
    command = "purge_queue"
  when '--report_vp_cluster_status'
    command = "report_vp_cluster_status"
  when '--queue_info'
    command = "queue_info"
  when '--vhost'
    vhost = arg
  when '--name'
    name = arg
  when '--url'
    url = arg
  when '--username'
    username = arg
  when '--password'  
    password = arg
  when '--threshold'
    threshold = arg.to_i
  end
end

rabbit = Rabbitmq.new("#{username}","#{password}","#{url}","#{threshold}")

case command
  when "list_queues"
    rabbit.list_queues
  when "report_vp_cluster_status"
    rabbit.report_vp_cluster_status
  when "purge_queue"
    rabbit.purge_queue(vhost,name)
  when "queue_info"
    pp rabbit.queue_info(vhost,name)
else
  puts "no command selected. Bye!  "
  exit 1
end
