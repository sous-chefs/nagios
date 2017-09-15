#
# Author:: Seth Chisamore <schisamo@chef.io>
# Author:: Tim Smith <tsmith@chef.io>
# Cookbook:: nagios
# Attributes:: default
#
# Copyright 2011-2016, Chef Software, Inc.
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

# Default vaules guarantee to exist, override in webserer recipe
default['nagios']['web_user']  = 'nagios'
default['nagios']['web_group'] = 'nagios'

# Allow specifying which interface on clients to monitor (which IP address to monitor)
default['nagios']['monitoring_interface'] = nil

case node['platform_family']
when 'debian'
  default['nagios']['plugin_dir'] = '/usr/lib/nagios/plugins'
when 'rhel', 'amazon'
  default['nagios']['plugin_dir'] = node['kernel']['machine'] == 'i686' ? '/usr/lib/nagios/plugins' : '/usr/lib64/nagios/plugins'
else
  default['nagios']['plugin_dir'] = '/usr/lib/nagios/plugins'
end

# platform specific directories
case node['platform_family']
when 'rhel', 'amazon'
  default['nagios']['home']          = '/var/spool/nagios'
  default['nagios']['conf_dir']      = '/etc/nagios'
  default['nagios']['resource_dir']  = '/etc/nagios'
  default['nagios']['config_dir']    = '/etc/nagios/conf.d'
  default['nagios']['log_dir']       = '/var/log/nagios'
  default['nagios']['cache_dir']     = '/var/log/nagios'
  default['nagios']['state_dir']     = '/var/log/nagios'
  default['nagios']['run_dir'] = if node['platform'] == 'centos' && node['platform_version'].to_i < 7
                                   '/var/run'
                                 else
                                   '/var/run/nagios'
                                 end
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
  default['nagios']['cgi-path'] = "/cgi-bin/#{node['nagios']['server']['service_name']}"
when 'rhel', 'amazon'
  default['nagios']['cgi-path'] = '/nagios/cgi-bin/'
  default['nagios']['server']['install_method'] = 'package'
  default['nagios']['server']['service_name']   = 'nagios'
  default['nagios']['server']['mail_command']   = '/bin/mail'
else
  default['nagios']['cgi-path'] = '/cgi-bin/nagios3'
  default['nagios']['server']['install_method'] = 'source'
  default['nagios']['server']['service_name']   = 'nagios'
  default['nagios']['server']['mail_command']   = '/bin/mail'
end

# webserver configuration
default['nagios']['enable_ssl']    = false
default['nagios']['http_port']     = node['nagios']['enable_ssl'] ? '443' : '80'
default['nagios']['server_name']   = node['fqdn']
default['nagios']['server']['server_alias'] = nil
default['nagios']['ssl_cert_file'] = "#{node['nagios']['conf_dir']}/certificates/nagios-server.pem"
default['nagios']['ssl_cert_key']  = "#{node['nagios']['conf_dir']}/certificates/nagios-server.pem"
default['nagios']['ssl_req']       = '/C=US/ST=Several/L=Locality/O=Example/OU=Operations/' \
  "CN=#{node['nagios']['server_name']}/emailAddress=ops@#{node['nagios']['server_name']}"
default['nagios']['ssl_protocols'] = 'all -SSLv3 -SSLv2'
default['nagios']['ssl_ciphers']   = nil

# nagios server name and webserver vname.  this can be changed to allow for the installation of icinga
default['nagios']['server']['name'] = 'nagios'
case node['platform_family']
when 'rhel', 'amazon'
  default['nagios']['server']['vname'] = 'nagios'
else
  default['nagios']['server']['vname'] = 'nagios3'
end

# for server from source installation
default['nagios']['server']['url']       = 'https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.2.4.tar.gz'
default['nagios']['server']['checksum']  = 'b0055c475683ce50d77b1536ff0cec9abf89139adecf771601fa021ef9a20b70'
default['nagios']['server']['src_dir']   = node['nagios']['server']['url'].split('/')[-1].chomp('.tar.gz')
default['nagios']['server']['patches']   = []
default['nagios']['server']['patch_url'] = nil

# for server from packages installation
case node['platform_family']
when 'rhel', 'amazon'
  default['nagios']['server']['packages'] = %w(nagios nagios-plugins-nrpe)
  default['nagios']['server']['install_yum-epel'] = true
else
  default['nagios']['server']['packages'] = %w(nagios3 nagios-nrpe-plugin nagios-images)
end

default['nagios']['check_external_commands']     = true
default['nagios']['default_contact_groups']      = %w(admins)
default['nagios']['default_user_name']           = nil
default['nagios']['sysadmin_email']              = 'root@localhost'
default['nagios']['sysadmin_sms_email']          = 'root@localhost'
default['nagios']['server_auth_method']          = 'htauth'
default['nagios']['server_auth_require']         = 'valid-user'
default['nagios']['users_databag']               = 'users'
default['nagios']['users_databag_group']         = 'sysadmin'
default['nagios']['services_databag']            = 'nagios_services'
default['nagios']['servicegroups_databag']       = 'nagios_servicegroups'
default['nagios']['templates_databag']           = 'nagios_templates'
default['nagios']['hosttemplates_databag']       = 'nagios_hosttemplates'
default['nagios']['eventhandlers_databag']       = 'nagios_eventhandlers'
default['nagios']['unmanagedhosts_databag']      = 'nagios_unmanagedhosts'
default['nagios']['serviceescalations_databag']  = 'nagios_serviceescalations'
default['nagios']['hostgroups_databag']          = 'nagios_hostgroups'
default['nagios']['hostescalations_databag']     = 'nagios_hostescalations'
default['nagios']['contacts_databag']            = 'nagios_contacts'
default['nagios']['contactgroups_databag']       = 'nagios_contactgroups'
default['nagios']['servicedependencies_databag'] = 'nagios_servicedependencies'
default['nagios']['timeperiods_databag']         = 'nagios_timeperiods'
default['nagios']['host_name_attribute']         = 'hostname'
default['nagios']['regexp_matching']             = 0
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
default['nagios']['ldap_group_attribute'] = nil
default['nagios']['ldap_group_attribute_is_dn'] = nil
default['nagios']['ldap_verify_cert'] = nil
default['nagios']['ldap_trusted_mode'] = nil
default['nagios']['ldap_trusted_global_cert'] = nil

default['nagios']['templates'] = Mash.new

default['nagios']['default_host']['flap_detection']        = true
default['nagios']['default_host']['process_perf_data']     = false
default['nagios']['default_host']['check_period']          = '24x7'
# Provide all interval values in seconds
default['nagios']['default_host']['check_interval']        = 15
default['nagios']['default_host']['retry_interval']        = 15
default['nagios']['default_host']['max_check_attempts']    = 1
default['nagios']['default_host']['check_command']         = 'check_host_alive'
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

default['nagios']['server']['web_server']              = 'apache'
default['nagios']['server']['nginx_dispatch']['type']  = 'both'
default['nagios']['server']['nginx_dispatch']['type']  = 'both'
default['nagios']['server']['nginx_dispatch']['packages']  =
  case node['platform_family']
  when 'rhel'
    %w(spawn-fcgi fcgiwrap)
  else
    %w(fcgiwrap)
  end
default['nagios']['server']['nginx_dispatch']['services']  =
  case node['platform_family']
  when 'rhel'
    %w(spawn-fcgi)
  else
    %w(fcgiwrap)
  end
default['nagios']['server']['nginx_dispatch']['cgi_url']  =
  'unix:/var/run/fcgiwrap.socket'
default['nagios']['server']['nginx_dispatch']['php_url']  =
  'unix:/var/run/php-fpm-www.sock'
default['nagios']['server']['stop_apache']             = false
default['nagios']['server']['normalize_hostname']      = false
default['nagios']['server']['load_default_config']     = true
default['nagios']['server']['load_databag_config']     = true
default['nagios']['server']['use_encrypted_data_bags'] = false

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
default['nagios']['cgi']['result_limit']                             = 100
default['nagios']['cgi']['escape_html_tags']                         = 0
default['nagios']['cgi']['action_url_target']                        = '_blank'
default['nagios']['cgi']['notes_url_target']                         = '_blank'
default['nagios']['cgi']['lock_author_names']                        = 1

default['nagios']['pagerduty']['script_url'] = 'https://raw.github.com/PagerDuty/pagerduty-nagios-pl/master/pagerduty_nagios.pl'
default['nagios']['pagerduty']['service_notification_options'] = 'w,u,c,r'
default['nagios']['pagerduty']['host_notification_options'] = 'd,r'

# atrributes for setting broker lines
default['nagios']['brokers'] = {}

# attribute defining tag used to exclude hosts
default['nagios']['exclude_tag_host'] = ''

# Set the prefork module for Apache as PHP is not thread-safe
default['apache']['mpm'] = 'prefork'

# attribute to add commands to source build
default['nagios']['source']['add_build_commands'] = ['make install-exfoliation']
default['nagios']['allowed_ips'] = []
