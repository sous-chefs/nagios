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
multi_env = node['nagios']['monitored_environments']
multi_env_search = multi_env.empty? ? '' : ' AND (chef_environment:' + multi_env.join(' OR chef_environment:') + ')'

if node['nagios']['multi_environment_monitoring']
  nodes = search(:node, "name:*#{multi_env_search}")
else
  nodes = search(:node, "chef_environment:#{node.chef_environment} AND node:*")
end

if nodes.empty?
  Chef::Log.info('No nodes returned from search, using this node so hosts.cfg has data')
  nodes << node
end

# Pushing current node to prevent empty hosts.cfg
Nagios.instance.push(node)

# Pushing all nodes into the Nagios.instance model
nodes.each { |n| Nagios.instance.push(n) }

# 24x7 timeperiod
nagios_timeperiod '24x7' do
  options 'alias' => '24 Hours A Day, 7 Days A Week',
          'times' => { 'sunday'    => '00:00-24:00',
                       'monday'    => '00:00-24:00',
                       'tuesday'   => '00:00-24:00',
                       'wednesday' => '00:00-24:00',
                       'thursday'  => '00:00-24:00',
                       'friday'    => '00:00-24:00',
                       'saturday'  => '00:00-24:00'
                     }
end

# Host checks
nagios_command 'check_host_alive' do
  options  'command_line' => '$USER1$/check_ping -H $HOSTADDRESS$ -w 2000,80% -c 3000,100% -p 1'
end

# Service checks
nagios_command 'check_nagios' do
  options 'command_line' => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_nagios -t 20'
end

# nrpe remote host checks
nagios_command 'check_nrpe_alive' do
  options 'command_line' => '$USER1$/check_nrpe -H $HOSTADDRESS$ -t 20'
end

nagios_command 'check_nrpe' do
  options 'command_line' => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 20'
end

# host_notify_by_email command
nagios_command 'host_notify_by_email' do
  options 'command_line' => '/usr/bin/printf "%b" "$LONGDATETIME$\n\n$HOSTALIAS$ $NOTIFICATIONTYPE$ $HOSTSTATE$\n\n$HOSTOUTPUT$\n\nLogin: ssh://$HOSTNAME$" | ' + node['nagios']['server']['mail_command'] + ' -s "$NOTIFICATIONTYPE$ - $HOSTALIAS$ $HOSTSTATE$!" $CONTACTEMAIL$'
end

# service_notify_by_email command
nagios_command 'service_notify_by_email' do
  options 'command_line' => '/usr/bin/printf "%b" "$LONGDATETIME$ - $SERVICEDESC$ $SERVICESTATE$\n\n$HOSTALIAS$  $NOTIFICATIONTYPE$\n\n$SERVICEOUTPUT$\n\nLogin: ssh://$HOSTNAME$" | ' + node['nagios']['server']['mail_command'] + ' -s "** $NOTIFICATIONTYPE$ - $HOSTALIAS$ - $SERVICEDESC$ - $SERVICESTATE$" $CONTACTEMAIL$'
end

# host_notify_by_sms_email command
nagios_command 'host_notify_by_sms_email' do
  options 'command_line' => '/usr/bin/printf "%b" "$HOSTALIAS$ $NOTIFICATIONTYPE$ $HOSTSTATE$\n\n$HOSTOUTPUT$" | ' + node['nagios']['server']['mail_command'] + ' -s "$HOSTALIAS$ $HOSTSTATE$!" $CONTACTPAGER$'
end

# root contact
nagios_contact 'root' do
  options 'alias'                         => 'Root',
          'service_notification_period'   => '24x7',
          'host_notification_period'      => '24x7',
          'service_notification_options'  => 'w,u,c,r',
          'host_notification_options'     => 'd,r',
          'service_notification_commands' => 'service_notify_by_email',
          'host_notification_commands'    => 'host_notify_by_email',
          'email'                         => 'root@localhost'
end

# admin contact
nagios_contact 'admin' do
  options 'alias'                         => 'Admin',
          'service_notification_period'   => '24x7',
          'host_notification_period'      => '24x7',
          'service_notification_options'  => 'w,u,c,r',
          'host_notification_options'     => 'd,r',
          'service_notification_commands' => 'service_notify_by_email',
          'host_notification_commands'    => 'host_notify_by_email'
end

nagios_contact 'default-contact' do
  options 'name'                            => 'default-contact',
          'service_notification_period'     => '24x7',
          'host_notification_period'        => '24x7',
          'service_notification_options'    => 'w,u,c,r,f',
          'host_notification_options'       => 'd,u,r,f,s',
          'service_notification_commands'   => 'service_notify_by_email',
          'host_notification_commands'      => 'host_notify_by_email'
end

# This was taken from the origional cookbook, but cannot find the
# commands service-notify-by-sms-gateway and host-notify-by-sms-gateway
# anywhere defined, so skipping this here.
#
# nagios_contact 'sms-contact' do
#   options 'name'                          => 'sms-contact',
#           'service_notification_period'   => '24x7',
#           'host_notification_period'      => '24x7',
#           'service_notification_options'  => 'w,u,c,r,f',
#           'host_notification_options'     => 'd,u,r,f,s',
#           'service_notification_commands' => 'service-notify-by-sms-gateway',
#           'host_notification_commands'    => 'host-notify-by-sms-gateway'
# end

nagios_host 'default-host' do
  options 'name'                         => 'default-host',
          'notifications_enabled'        => 1,
          'event_handler_enabled'        => 1,
          'flap_detection_enabled'       => nagios_boolean(nagios_attr(:default_host)[:flap_detection]),
          'process_perf_data'            => nagios_boolean(nagios_attr(:default_host)[:process_perf_data]),
          'retain_status_information'    => 1,
          'retain_nonstatus_information' => 1,
          'notification_period'          => '24x7',
          'register'                     => 0,
          'action_url'                   => nagios_attr(:default_host)[:action_url]
end

nagios_host 'server' do
  options 'name'                   => 'server',
          'use'                    => 'default-host',
          'check_period'           => nagios_attr(:default_host)[:check_period],
          'check_interval'         => nagios_interval(nagios_attr(:default_host)[:check_interval]),
          'retry_interval'         => nagios_interval(nagios_attr(:default_host)[:retry_interval]),
          'max_check_attempts'     => nagios_attr(:default_host)[:max_check_attempts],
          'check_command'          => nagios_attr(:default_host)[:check_command],
          'notification_interval'  => nagios_interval(nagios_attr(:default_host)[:notification_interval]),
          'notification_options'   => nagios_attr(:default_host)[:notification_options],
          'contact_groups'         => nagios_attr(:default_contact_groups),
          'register'               => 0
end

# Defaut host template
Nagios.instance.default_host = node['nagios']['host_template']

# Users
# use the users_helper.rb library to build arrays of users and contacts
nagios_users = NagiosUsers.new(node)
nagios_users.users.each do |item|
  o = Nagios::Contact.create(item['id'])
  o.import(item.to_hash)
  o.import(item['nagios'].to_hash) unless item['nagios'].nil?
  o.use = 'default-contact'
end

nagios_contactgroup 'admins' do
  options 'alias'   => 'Nagios Administrators',
          'members' => nagios_users.return_user_contacts
end

nagios_contactgroup 'admins-sms' do
  options 'alias'   => 'Sysadmin SMS',
          'members' => nagios_users.return_user_contacts
end

# Services
nagios_service 'default-service' do
  options 'name'                         => 'default-service',
          'active_checks_enabled'        => 1,
          'passive_checks_enabled'       => 1,
          'parallelize_check'            => 1,
          'obsess_over_service'          => 1,
          'check_freshness'              => 0,
          'notifications_enabled'        => 1,
          'event_handler_enabled'        => 1,
          'flap_detection_enabled'       => nagios_boolean(nagios_attr(:default_service)[:flap_detection]),
          'process_perf_data'            => nagios_boolean(nagios_attr(:default_service)[:process_perf_data]),
          'retain_status_information'    => 1,
          'retain_nonstatus_information' => 1,
          'is_volatile'                  => 0,
          'check_period'                 => '24x7',
          'max_check_attempts'           => nagios_attr(:default_service)[:max_check_attempts],
          'check_interval'               => nagios_interval(nagios_attr(:default_service)[:check_interval]),
          'retry_interval'               => nagios_interval(nagios_attr(:default_service)[:retry_interval]),
          'contact_groups'               => nagios_attr(:default_contact_groups),
          'notification_options'         => 'w,u,c,r',
          'notification_interval'        => nagios_interval(nagios_attr(:default_service)[:notification_interval]),
          'notification_period'          => '24x7',
          'register'                     => 0,
          'action_url'                   => nagios_attr(:default_service)[:action_url]
end
# Default service template
Nagios.instance.default_service = 'default-service'

# Define the log monitoring template (monitoring logs is very different)
nagios_service 'default-logfile' do
  options 'name'                   => 'default-logfile',
          'use'                    => 'default-service',
          'check_period'           => '24x7',
          'max_check_attempts'     => 1,
          'check_interval'         => nagios_interval(nagios_attr(:default_service)[:check_interval]),
          'retry_interval'         => nagios_interval(nagios_attr(:default_service)[:retry_interval]),
          'contact_groups'         => nagios_attr(:default_contact_groups),
          'notification_options'   => 'w,u,c,r',
          'notification_period'    => '24x7',
          'register'               => 0,
          'is_volatile'            => 1
end

nagios_service 'service-template' do
  options 'name'                  => 'service-template',
          'max_check_attempts'    => nagios_attr(:default_service)[:max_check_attempts],
          'check_interval'        => nagios_interval(nagios_attr(:default_service)[:check_interval]),
          'retry_interval'        => nagios_interval(nagios_attr(:default_service)[:retry_interval]),
          'notification_interval' => nagios_interval(nagios_attr(:default_service)[:notification_interval]),
          'register'              => 0
end

nagios_resource 'USER1' do
  options 'value' => node['nagios']['plugin_dir']
end
