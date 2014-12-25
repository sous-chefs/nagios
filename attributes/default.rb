#
# Author:: Seth Chisamore <schisamo@getchef.com>
# Author:: Tim Smith <tim@cozy.co>
# Cookbook Name:: nagios
# Attributes:: default
#
# Copyright 2011-2013, Chef Software, Inc.
# Copyright 2013-2014, Limelight Networks, Inc
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

# Allow a Nagios server to monitor hosts in multiple environments.
default['nagios']['multi_environment_monitoring'] = false
default['nagios']['monitored_environments'] = []

default['nagios']['user']  = 'nagios'
default['nagios']['group'] = 'nagios'

# Allow specifying which interface on clients to monitor (which IP address to monitor)
default['nagios']['monitoring_interface'] = nil

case node['platform_family']
when 'debian'
  default['nagios']['plugin_dir'] = '/usr/lib/nagios/plugins'
when 'rhel', 'fedora'
  if node['kernel']['machine'] == 'i686'
    default['nagios']['plugin_dir'] = '/usr/lib/nagios/plugins'
  else
    default['nagios']['plugin_dir'] = '/usr/lib64/nagios/plugins'
  end
else
  default['nagios']['plugin_dir'] = '/usr/lib/nagios/plugins'
end

# platform specific directories
case node['platform_family']
when 'rhel', 'fedora'
  default['nagios']['home']          = '/var/spool/nagios'
  default['nagios']['conf_dir']      = '/etc/nagios'
  default['nagios']['resource_dir']  = '/etc/nagios'
  default['nagios']['config_dir']    = '/etc/nagios/conf.d'
  default['nagios']['log_dir']       = '/var/log/nagios'
  default['nagios']['cache_dir']     = '/var/log/nagios'
  default['nagios']['state_dir']     = '/var/log/nagios'
  default['nagios']['run_dir']       = '/var/run'
  default['nagios']['docroot']       = '/usr/share/nagios/html'
  default['nagios']['cgi-bin']       = '/usr/lib64/nagios/cgi-bin/'
else
  default['nagios']['home']          = '/usr/lib/nagios3'
  default['nagios']['conf_dir']      = '/etc/nagios3'
  default['nagios']['resource_dir']  = '/etc/nagios3'
  default['nagios']['config_dir']    = '/etc/nagios3/conf.d'
  default['nagios']['log_dir']       = '/var/log/nagios3'
  default['nagios']['cache_dir']     = '/var/cache/nagios3'
  default['nagios']['state_dir']     = '/var/lib/nagios3'
  default['nagios']['run_dir']       = '/var/run/nagios3'
  default['nagios']['docroot']       = '/usr/share/nagios3/htdocs'
  default['nagios']['cgi-bin']       = '/usr/lib/cgi-bin/nagios3'
end

# platform specific atttributes
case node['platform_family']
when 'debian'
  default['nagios']['server']['install_method'] = 'package'
  default['nagios']['server']['service_name']   = 'nagios3'
  default['nagios']['server']['mail_command']   = '/usr/bin/mail'
  default['nagios']['conf']['p1_file']          = "#{node['nagios']['home']}/p1.pl"
  default['nagios']['cgi-path']       = "/cgi-bin/#{node['nagios']['server']['service_name']}"
when 'rhel', 'fedora'
  default['nagios']['conf']['p1_file']          = '/usr/sbin/p1.pl'
  default['nagios']['cgi-path']       = '/nagios/cgi-bin/'
  # install via source on RHEL releases less than 6, otherwise use packages
  if node['platform_family'] == 'rhel' && node['platform_version'].to_i < 6
    default['nagios']['server']['install_method'] = 'source'
  else
    default['nagios']['server']['install_method'] = 'package'
  end
  default['nagios']['server']['service_name']   = 'nagios'
  default['nagios']['server']['mail_command']   = '/bin/mail'
else
  default['nagios']['server']['install_method'] = 'source'
  default['nagios']['server']['service_name']   = 'nagios'
  default['nagios']['server']['mail_command']   = '/bin/mail'
  default['nagios']['conf']['p1_file']          = "#{node['nagios']['home']}/p1.pl"
end

# webserver configuration
default['nagios']['timezone']      = 'UTC'
default['nagios']['enable_ssl']    = false
default['nagios']['http_port']     = node['nagios']['enable_ssl'] ? '443' : '80'
default['nagios']['server_name']   = node['fqdn']
default['nagios']['server_alias']   = nil
default['nagios']['ssl_cert_file'] = "#{node['nagios']['conf_dir']}/certificates/nagios-server.pem"
default['nagios']['ssl_cert_key']  = "#{node['nagios']['conf_dir']}/certificates/nagios-server.pem"
default['nagios']['ssl_req']       = '/C=US/ST=Several/L=Locality/O=Example/OU=Operations/' \
  "CN=#{node['nagios']['server_name']}/emailAddress=ops@#{node['nagios']['server_name']}"

# nagios server name and webserver vname.  this can be changed to allow for the installation of icinga
default['nagios']['server']['name']  = 'nagios'
case node['platform_family']
when 'rhel', 'fedora'
  default['nagios']['server']['vname'] = 'nagios'
else
  default['nagios']['server']['vname'] = 'nagios3'
end

# for server from source installation
default['nagios']['server']['url']      = 'http://iweb.dl.sourceforge.net/project/nagios/nagios-4.x/nagios-4.0.8/nagios-4.0.8.tar.gz'
default['nagios']['server']['checksum'] = '8b268d250c97851775abe162f46f64724f95f367d752ae4630280cc5d368ca4b'
default['nagios']['server']['src_dir']  = node['nagios']['server']['url'].split('/')[-1].chomp('.tar.gz')
default['nagios']['server']['patch_url'] = nil
default['nagios']['server']['patches']  = []

# for server from packages installation
case node['platform_family']
when 'rhel', 'fedora'
  default['nagios']['server']['packages'] = %w(nagios nagios-plugins-nrpe)
else
  default['nagios']['server']['packages'] = %w(nagios3 nagios-nrpe-plugin nagios-images)
end

default['nagios']['notifications_enabled']         = 0
default['nagios']['execute_service_checks']        = 1
default['nagios']['accept_passive_service_checks'] = 1
default['nagios']['execute_host_checks']           = 1
default['nagios']['accept_passive_host_checks']    = 1

default['nagios']['obsess_over_services'] = 0
default['nagios']['ocsp_command']         = nil
default['nagios']['obsess_over_hosts']    = 0
default['nagios']['ochp_command']         = nil

default['nagios']['check_external_commands']     = true
default['nagios']['default_contact_groups']      = %w(admins)
default['nagios']['sysadmin_email']              = 'root@localhost'
default['nagios']['sysadmin_sms_email']          = 'root@localhost'
default['nagios']['server_auth_method']          = 'htauth'
default['nagios']['users_databag']               = 'users'
default['nagios']['users_databag_group']         = 'sysadmin'
default['nagios']['services_databag']            = 'nagios_services'
default['nagios']['servicegroups_databag']       = 'nagios_servicegroups'
default['nagios']['templates_databag']           = 'nagios_templates'
default['nagios']['hosttemplates_databag']       = 'nagios_hosttemplates'
default['nagios']['eventhandlers_databag']       = 'nagios_eventhandlers'
default['nagios']['unmanagedhosts_databag']      = 'nagios_unmanagedhosts'
default['nagios']['serviceescalations_databag']  = 'nagios_serviceescalations'
default['nagios']['hostescalations_databag']     = 'nagios_hostescalations'
default['nagios']['contacts_databag']            = 'nagios_contacts'
default['nagios']['contactgroups_databag']       = 'nagios_contactgroups'
default['nagios']['servicedependencies_databag'] = 'nagios_servicedependencies'
default['nagios']['timeperiods_databag']         = 'nagios_timeperiods'
default['nagios']['host_name_attribute']         = 'hostname'
default['nagios']['regexp_matching']             = 0
default['nagios']['large_installation_tweaks']   = 0
default['nagios']['host_template'] = 'server'

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

default['nagios']['templates']       = Mash.new

# This setting is effectively sets the minimum interval (in seconds) nagios can handle.
# Other interval settings provided in seconds will calculate their actual from this value, since nagios works in 'time units' rather than allowing definitions everywhere in seconds
default['nagios']['interval_length'] = 1

default['nagios']['default_host']['flap_detection']        = true
default['nagios']['default_host']['process_perf_data']     = false
default['nagios']['default_host']['check_period']          = '24x7'
# Provide all interval values in seconds
default['nagios']['default_host']['check_interval']        = 15
default['nagios']['default_host']['retry_interval']        = 15
default['nagios']['default_host']['max_check_attempts']    = 1
default['nagios']['default_host']['check_command']         = 'check-host-alive'
default['nagios']['default_host']['notification_interval'] = 300
default['nagios']['default_host']['notification_options']  = 'd,u,r'
default['nagios']['default_host']['action_url']            = nil

default['nagios']['default_service']['check_interval']        = 60
default['nagios']['default_service']['process_perf_data']     = false
default['nagios']['default_service']['retry_interval']        = 15
default['nagios']['default_service']['max_check_attempts']    = 3
default['nagios']['default_service']['notification_interval'] = 1200
default['nagios']['default_service']['flap_detection']        = true
default['nagios']['default_service']['action_url']            = nil

default['nagios']['server']['web_server']     = 'apache'
default['nagios']['server']['nginx_dispatch'] = 'cgi'
default['nagios']['server']['stop_apache']    = false
default['nagios']['server']['normalize_hostname'] = false

default['nagios']['conf']['max_service_check_spread'] = 5
default['nagios']['conf']['max_host_check_spread']    = 5
default['nagios']['conf']['service_check_timeout']    = 60
default['nagios']['conf']['host_check_timeout']       = 30
default['nagios']['conf']['process_performance_data'] = 0
default['nagios']['conf']['date_format']              = 'iso8601'
default['nagios']['conf']['debug_level']              = 0
default['nagios']['conf']['debug_verbosity']          = 1
default['nagios']['conf']['debug_file']               = "#{node['nagios']['state_dir']}/#{node['nagios']['server']['name']}.debug"

default['nagios']['cgi']['show_context_help']                        = 1
default['nagios']['cgi']['authorized_for_system_information']        = '*'
default['nagios']['cgi']['authorized_for_configuration_information'] = '*'
default['nagios']['cgi']['authorized_for_system_commands']           = '*'
default['nagios']['cgi']['authorized_for_all_services']              = '*'
default['nagios']['cgi']['authorized_for_all_hosts']                 = '*'
default['nagios']['cgi']['authorized_for_all_service_commands']      = '*'
default['nagios']['cgi']['authorized_for_all_host_commands']         = '*'
default['nagios']['cgi']['default_statusmap_layout']                 = 5
default['nagios']['cgi']['default_statuswrl_layout']                 = 4
default['nagios']['cgi']['escape_html_tags']                         = 0
default['nagios']['cgi']['action_url_target']                        = '_blank'
default['nagios']['cgi']['notes_url_target']                         = '_blank'
default['nagios']['cgi']['lock_author_names']                        = 1

# backwards compatibility for the old attribute structure
node.set['nagios']['pagerduty']['key'] = node['nagios']['pagerduty_key']

default['nagios']['pagerduty']['key'] = ''
default['nagios']['pagerduty']['script_url'] = 'https://raw.github.com/PagerDuty/pagerduty-nagios-pl/master/pagerduty_nagios.pl'
default['nagios']['pagerduty']['service_notification_options'] = 'w,u,c,r'
default['nagios']['pagerduty']['host_notification_options'] = 'd,r'

# atrributes for setting broker lines
default['nagios']['brokers'] = {}

# attribute defining tag used to exclude hosts
default['nagios']['exclude_tag_host'] = ''
