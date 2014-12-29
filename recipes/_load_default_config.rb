#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Recipe:: _load_default_config
#
# Copyright 2014, Sander Botman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Find nodes to monitor.  
# Search in all environments if multi_environment_monitoring is enabled.
Chef::Log.info('Beginning search for nodes.  This may take some time depending on your node count')

nodes = []
hostgroups = []
multi_env = node['nagios']['monitored_environments']
multi_env_search = multi_env.empty? ? '' : ' AND (chef_environment:' + multi_env.join(' OR chef_environment:') + ')'

if node['nagios']['multi_environment_monitoring']
  nodes = search(:node, "name:*#{multi_env_search}")
else
  nodes = search(:node, "name:* AND chef_environment:#{node.chef_environment}")
end

if nodes.empty?
  Chef::Log.info('No nodes returned from search, using this node so hosts.cfg has data')
  nodes << node
end

# Pushing all nodes into the Nagios.instance model
nodes.each { |n| Nagios.instance.push(n) }

# 24x7 timeperiod
t = Nagios::Timeperiod.create('24x7')
t.alias = '24 Hours A Day, 7 Days A Week'
%w( sunday
    monday
    tuesday
    wednesday
    thursday
    friday
    saturday
).each do |day|
  t.push(Nagios::Timeperiodentry.new(day, '00:00-24:00'))
end

# Host checks
check_host_alive = Nagios::Command.create('check_host_alive')
check_host_alive.command_line = '$USER1$/check_ping -H $HOSTADDRESS$ -w 2000,80% -c 3000,100% -p 1'

# Service checks
check_nagios = Nagios::Command.create('check_nagios')
check_nagios.command_line = '$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_nagios -t 20'

# nrpe remote host checks
check_nrpe_alive = Nagios::Command.create('check_nrpe_alive')
check_nrpe_alive.command_line = '$USER1$/check_nrpe -H $HOSTADDRESS$ -t 20'

check_nrpe = Nagios::Command.create('check_nrpe')
check_nrpe.command_line = '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 20'

# host_notify_by_email command
host_notify_by_email = Nagios::Command.create('host_notify_by_email')
host_notify_by_email.command_line = '/usr/bin/printf "%b" "$LONGDATETIME$\n\n$HOSTALIAS$ $NOTIFICATIONTYPE$ $HOSTSTATE$\n\n$HOSTOUTPUT$\n\nLogin: ssh://$HOSTNAME$" | ' + node['nagios']['server']['mail_command'] + ' -s "$NOTIFICATIONTYPE$ - $HOSTALIAS$ $HOSTSTATE$!" $CONTACTEMAIL$'

# service_notify_by_email command
service_notify_by_email = Nagios::Command.create('service_notify_by_email')
service_notify_by_email.command_line = '/usr/bin/printf "%b" "$LONGDATETIME$ - $SERVICEDESC$ $SERVICESTATE$\n\n$HOSTALIAS$  $NOTIFICATIONTYPE$\n\n$SERVICEOUTPUT$\n\nLogin: ssh://$HOSTNAME$" | ' + node['nagios']['server']['mail_command'] + ' -s "** $NOTIFICATIONTYPE$ - $HOSTALIAS$ - $SERVICEDESC$ - $SERVICESTATE$" $CONTACTEMAIL$'

# host_notify_by_sms_email command
host_notify_by_sms_email = Nagios::Command.create('host_notify_by_sms_email')
host_notify_by_sms_email.command_line = '/usr/bin/printf "%b" "$HOSTALIAS$ $NOTIFICATIONTYPE$ $HOSTSTATE$\n\n$HOSTOUTPUT$" | ' + node['nagios']['server']['mail_command'] + ' -s "$HOSTALIAS$ $HOSTSTATE$!" $CONTACTPAGER$'

# root contact
c = Nagios::Contact.create('root')
options = { 
  'alias'                         => 'Root',
  'service_notification_period'   => t,
  'host_notification_period'      => t,
  'service_notification_options'  => 'w,u,c,r',
  'host_notification_options'     => 'd,r',
  'service_notification_commands' => service_notify_by_email,
  'host_notification_commands'    => host_notify_by_email,
  'email'                         => 'root@localhost'
}
c.import_hash(options)

# admin contact
c = Nagios::Contact.create('admin')
c.alias                         = 'Admin'
c.service_notification_period   = t
c.host_notification_period      = t
c.service_notification_options  = 'w,u,c,r'
c.host_notification_options     = 'd,r'
c.service_notification_commands = service_notify_by_email
c.host_notification_commands    = host_notify_by_email

c = Nagios::Contact.create('default-contact')
c.name                            = 'default-contact'
c.service_notification_period     = t
c.host_notification_period        = t
c.service_notification_options    = 'w,u,c,r,f'
c.host_notification_options       = 'd,u,r,f,s'
c.service_notification_commands   = service_notify_by_email
c.host_notification_commands      = host_notify_by_email

# This was taken from the origional cookbook, but cannot find the
# commands service-notify-by-sms-gateway and host-notify-by-sms-gateway
# anywhere defined, so skipping this here.
#
# c = Nagios::Contact.create('sms-contact')
# c.name                            = 'sms-contact'
# c.service_notification_period     = t
# c.host_notification_period        = t
# c.service_notification_options    = 'w,u,c,r,f'
# c.host_notification_options       = 'd,u,r,f,s'
# c.service_notification_commands   = service-notify-by-sms-gateway
# c.host_notification_commands      = host-notify-by-sms-gateway

h = Nagios::Host.create('default-host')
h.name                         = 'default-host'
h.notifications_enabled        = 1
h.event_handler_enabled        = 1
h.flap_detection_enabled       = nagios_boolean(nagios_attr(:default_host)[:flap_detection])
h.process_perf_data            = nagios_boolean(nagios_attr(:default_host)[:process_perf_data])
h.retain_status_information    = 1
h.retain_nonstatus_information = 1
h.notification_period          = t
h.register                     = 0
h.action_url                   = nagios_attr(:default_host)[:action_url]

h = Nagios::Host.create('server')
h.name                    = 'server'
h.use                     = 'default-host'
h.check_period            = nagios_attr(:default_host)[:check_period]
h.check_interval          = nagios_interval(nagios_attr(:default_host)[:check_interval])
h.retry_interval          = nagios_interval(nagios_attr(:default_host)[:retry_interval])
h.max_check_attempts      = nagios_attr(:default_host)[:max_check_attempts]
h.check_command           = nagios_attr(:default_host)[:check_command]
h.notification_interval   = nagios_interval(nagios_attr(:default_host)[:notification_interval])
h.notification_options    = nagios_attr(:default_host)[:notification_options]
nagios_attr(:default_contact_groups).each {|c| h.push(Nagios::Contactgroup.create(c)) }
h.register                = 0

# Defaut host template
Nagios.instance.default_host = h

#Services
s = Nagios::Service.create('default-service')
s.name                            = 'default-service'
s.active_checks_enabled           = 1
s.passive_checks_enabled          = 1
s.parallelize_check               = 1
s.obsess_over_service             = 1
s.check_freshness                 = 0
s.notifications_enabled           = 1
s.event_handler_enabled           = 1
s.flap_detection_enabled          = nagios_boolean(nagios_attr(:default_service)[:flap_detection])
s.process_perf_data               = nagios_boolean(nagios_attr(:default_service)[:process_perf_data])
s.retain_status_information       = 1
s.retain_nonstatus_information    = 1
s.is_volatile                     = 0
s.check_period                    = t
s.max_check_attempts              = nagios_attr(:default_service)[:max_check_attempts]
s.check_interval                  = nagios_interval(nagios_attr(:default_service)[:check_interval])
s.retry_interval                  = nagios_interval(nagios_attr(:default_service)[:retry_interval])
nagios_attr(:default_contact_groups).each {|c| s.push(Nagios::Contactgroup.create(c)) }
s.notification_options            = 'w,u,c,r'
s.notification_interval           = nagios_interval(nagios_attr(:default_service)[:notification_interval])
s.notification_period             = t
s.register                        = 0
s.action_url                      = nagios_attr(:default_service)[:action_url]

# Default service template
Nagios.instance.default_service = s

# Define the log monitoring template (monitoring logs is very different)
s = Nagios::Service.create('default-logfile')
s.name                            = 'default-logfile'
s.use                             = 'default-service'
s.check_period                    = t
s.max_check_attempts              = 1
s.check_interval                  = nagios_interval(nagios_attr(:default_service)[:check_interval])
s.retry_interval                  = nagios_interval(nagios_attr(:default_service)[:retry_interval])
nagios_attr(:default_contact_groups).each {|c| s.push(Nagios::Contactgroup.create(c)) }
s.notification_options            = 'w,u,c,r'
s.notification_period             = t
s.register                        = 0
s.is_volatile                     = 1

s = Nagios::Service.create('service-template')
s.name                            = 'service-template'
s.max_check_attempts              = nagios_attr(:default_service)[:max_check_attempts]
s.check_interval                  = nagios_interval(nagios_attr(:default_service)[:check_interval])
s.retry_interval                  = nagios_interval(nagios_attr(:default_service)[:retry_interval])
s.notification_interval           = nagios_interval(nagios_attr(:default_service)[:notification_interval])
s.register                        = 0

