# Author:: Joshua Sierles <joshua@37signals.com>
#
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Attributes:: server
#
# Copyright 2009, 37signals
# Copyright 2009-2013, Opscode, Inc
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

node.set['nagios']['pagerduty']['key'] = node['nagios']['pagerduty_key']
default['nagios']['pagerduty']['key'] = ''
unless node['nagios']['pagerduty']['key'].empty?
  default['nagios']['additional_contacts'] = { 'pagerduty' => true }
end
default['nagios']['pagerduty']['script_url'] = 'https://raw.github.com/PagerDuty/pagerduty-nagios-pl/master/pagerduty_nagios.pl'
default['nagios']['pagerduty']['service_notification_options'] = 'w,u,c,r'
default['nagios']['pagerduty']['host_notification_options'] = 'd,r'

case node['platform_family']
when 'debian'
  default['nagios']['server']['install_method'] = 'package'
  default['nagios']['server']['service_name']   = 'nagios3'
  default['nagios']['server']['mail_command']   = '/usr/bin/mail'
when 'rhel', 'fedora'
  default['nagios']['server']['install_method'] = 'source'
  default['nagios']['server']['service_name']   = 'nagios'
  default['nagios']['server']['mail_command']   = '/bin/mail'
else
  default['nagios']['server']['install_method'] = 'source'
  default['nagios']['server']['service_name']   = 'nagios'
  default['nagios']['server']['mail_command']   = '/bin/mail'
end

default['nagios']['home']          = '/usr/lib/nagios3'
default['nagios']['conf_dir']      = '/etc/nagios3'
default['nagios']['config_dir']    = '/etc/nagios3/conf.d'
default['nagios']['log_dir']       = '/var/log/nagios3'
default['nagios']['cache_dir']     = '/var/cache/nagios3'
default['nagios']['state_dir']     = '/var/lib/nagios3'
default['nagios']['run_dir']       = '/var/run/nagios3'
default['nagios']['docroot']       = '/usr/share/nagios3/htdocs'
default['nagios']['timezone']      = 'UTC'
default['nagios']['enable_ssl']    = false
default['nagios']['http_port']     = node['nagios']['enable_ssl'] ? '443' : '80'
default['nagios']['server_name']   = node.key?(:domain) ? "nagios.#{domain}" : 'nagios'
default['nagios']['ssl_cert_file'] = "#{node['nagios']['conf_dir']}/certificates/nagios-server.pem"
default['nagios']['ssl_cert_key']  = "#{node['nagios']['conf_dir']}/certificates/nagios-server.pem"
default['nagios']['ssl_req']       = '/C=US/ST=Several/L=Locality/O=Example/OU=Operations/' +
  "CN=#{node['nagios']['server_name']}/emailAddress=ops@#{node['nagios']['server_name']}"

# nagios server name and webserver vname.  this can be changed to allow for the installation of icinga
default['nagios']['server']['name']  = 'nagios'
default['nagios']['server']['vname'] = 'nagios3'

# for server from source installation
default['nagios']['server']['url']      = 'http://prdownloads.sourceforge.net/sourceforge/nagios'
default['nagios']['server']['version']  = '3.5.1'
default['nagios']['server']['checksum'] = 'ca9dd68234fa090b3c35ecc8767b2c9eb743977eaf32612fa9b8341cc00a0f99'
default['nagios']['server']['src_dir'] = 'nagios'

# for server from packages installation
default['nagios']['server']['packages'] = %w[nagios3 nagios-nrpe-plugin nagios-images]

default['nagios']['notifications_enabled']     = 0
default['nagios']['check_external_commands']   = true
default['nagios']['default_contact_groups']    = %w{admins}
default['nagios']['sysadmin_email']            = 'root@localhost'
default['nagios']['sysadmin_sms_email']        = 'root@localhost'
default['nagios']['server_auth_method']        = 'htauth'
default['nagios']['users_databag']             = 'users'
default['nagios']['users_databag_group']       = 'sysadmin'
default['nagios']['host_name_attribute']       = 'hostname'
default['nagios']['regexp_matching']           = 0
default['nagios']['large_installation_tweaks'] = 0

# for cas authentication
default['nagios']['cas_login_url']       = 'https://example.com/cas/login'
default['nagios']['cas_validate_url']    = 'https://example.com/cas/serviceValidate'
default['nagios']['cas_validate_server'] = 'off'
default['nagios']['cas_root_proxy_url']  = nil

# for apache ldap authentication
default['nagios']['ldap_bind_dn']       = nil
default['nagios']['ldap_bind_password'] = nil
default['nagios']['ldap_url']           = nil
default['nagios']['ldap_authoritative'] = nil

# This setting is effectively sets the minimum interval (in seconds) nagios can handle.
# Other interval settings provided in seconds will calculate their actual from this value, since nagios works in 'time units' rather than allowing definitions everywhere in seconds

default['nagios']['templates']       = Mash.new
default['nagios']['interval_length'] = 1

default['nagios']['default_host']['flap_detection']        = true
default['nagios']['default_host']['check_period']          = '24x7'
# Provide all interval values in seconds
default['nagios']['default_host']['check_interval']        = 15
default['nagios']['default_host']['retry_interval']        = 15
default['nagios']['default_host']['max_check_attempts']    = 1
default['nagios']['default_host']['check_command']         = 'check-host-alive'
default['nagios']['default_host']['notification_interval'] = 300
default['nagios']['default_host']['notification_options']  = 'd,u,r'

default['nagios']['default_service']['check_interval']        = 60
default['nagios']['default_service']['retry_interval']        = 15
default['nagios']['default_service']['max_check_attempts']    = 3
default['nagios']['default_service']['notification_interval'] = 1200
default['nagios']['default_service']['flap_detection']        = true

default['nagios']['server']['web_server']     = :apache
default['nagios']['server']['nginx_dispatch'] = :cgi
default['nagios']['server']['stop_apache']    = false
default['nagios']['server']['redirect_root']  = false
default['nagios']['server']['normalize_hostname'] = false
# array of hostnames to exclude from being monitored
default['nagios']['server']['exclude_hosts'] = []
