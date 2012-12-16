#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Attributes:: server
#
# Copyright 2009, 37signals
# Copyright 2009-2011, Opscode, Inc
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
#

default['nagios']['pagerduty_key'] = ''

case node['platform_family']
when 'debian'
  default['nagios']['server']['install_method'] = 'package'
  default['nagios']['server']['service_name']   = 'nagios3'
  default['nagios']['server']['mail_command']   = '/usr/bin/mail'
when 'rhel','fedora'
  default['nagios']['server']['install_method'] = 'source'
  default['nagios']['server']['service_name']   = 'nagios'
  default['nagios']['server']['mail_command']   = '/bin/mail'
else
  default['nagios']['server']['install_method'] = 'source'
  default['nagios']['server']['service_name']   = 'nagios'
  default['nagios']['server']['mail_command']   = '/bin/mail'
end

default['nagios']['home']       = '/usr/lib/nagios3'
default['nagios']['conf_dir']   = '/etc/nagios3'
default['nagios']['config_dir'] = '/etc/nagios3/conf.d'
default['nagios']['log_dir']    = '/var/log/nagios3'
default['nagios']['cache_dir']  = '/var/cache/nagios3'
default['nagios']['state_dir']  = '/var/lib/nagios3'
default['nagios']['run_dir']    = '/var/run/nagios3'
default['nagios']['docroot']    = '/usr/share/nagios3/htdocs'
default['nagios']['enable_ssl'] = false
default['nagios']['http_port']  = node['nagios']['enable_ssl'] ? '443' : '80'
default['nagios']['server_name'] = node.has_key?(:domain) ? "nagios.#{domain}" : 'nagios'
default['nagios']['ssl_req'] = '/C=US/ST=Several/L=Locality/O=Example/OU=Operations/' +
  "CN=#{node['nagios']['server_name']}/emailAddress=ops@#{node['nagios']['server_name']}"

# for server from source installation
default['nagios']['server']['url']      = 'http://prdownloads.sourceforge.net/sourceforge/nagios'
default['nagios']['server']['version']  = '3.4.3'
default['nagios']['server']['checksum'] = '2d5c0cc56bafb08a71840a6efa349afc1eebb2761fea0d403e1b929e7c801b10'

default['nagios']['notifications_enabled']   = 0
default['nagios']['check_external_commands'] = true
default['nagios']['default_contact_groups']  = %w{admins}
default['nagios']['sysadmin_email']          = "root@localhost"
default['nagios']['sysadmin_sms_email']      = "root@localhost"
default['nagios']['server_auth_method']      = "openid"
default['nagios']['users_databag_group']     = "sysadmin"

# This setting is effectively sets the minimum interval (in seconds) nagios can handle.
# Other interval settings provided in seconds will calculate their actual from this value, since nagios works in 'time units' rather than allowing definitions everywhere in seconds

default['nagios']['templates'] = Mash.new
default['nagios']['interval_length'] = 1

# Provide all interval values in seconds
default['nagios']['default_host']['check_interval']     = 15
default['nagios']['default_host']['retry_interval']     = 15
default['nagios']['default_host']['max_check_attempts'] = 1
default['nagios']['default_host']['notification_interval'] = 300
default['nagios']['default_host']['flap_detection'] = true

default['nagios']['default_service']['check_interval']     = 60
default['nagios']['default_service']['retry_interval']     = 15
default['nagios']['default_service']['max_check_attempts'] = 3
default['nagios']['default_service']['notification_interval'] = 1200
default['nagios']['default_service']['flap_detection'] = true

default['nagios']['server']['web_server'] = :apache
default['nagios']['server']['nginx_dispatch'] = :cgi
default['nagios']['server']['stop_apache'] = false
default['nagios']['server']['redirect_root'] = false
