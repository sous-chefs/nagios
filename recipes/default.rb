#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@getchef.com>
# Author:: Nathan Haneysmith <nathan@getchef.com>
# Author:: Seth Chisamore <schisamo@getchef.com>
# Author:: Tim Smith <tim@cozy.co>
# Cookbook Name:: nagios
# Recipe:: default
#
# Copyright 2009, 37signals
# Copyright 2009-2013, Chef Software, Inc.
# Copyright 2013-2014, Limelight Networks, Inc.
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

# workaround to allow for a nagios server install from source using the override attribute on debian/ubuntu (COOK-2350)
if platform_family?('debian') && node['nagios']['server']['install_method'] == 'source'
  nagios_service_name = node['nagios']['server']['name']
else
  nagios_service_name = node['nagios']['server']['service_name']
end

# install nagios service either from source of package
include_recipe "nagios::server_#{node['nagios']['server']['install_method']}"

# configure either Apache2 or NGINX
case node['nagios']['server']['web_server']
when 'nginx'
  Chef::Log.info 'Setting up Nagios server via NGINX'
  include_recipe 'nagios::nginx'
  web_user = node['nginx']['user']
  web_group = node['nginx']['group'] || web_user
when 'apache'
  Chef::Log.info 'Setting up Nagios server via Apache2'
  include_recipe 'nagios::apache'
  web_user = node['apache']['user']
  web_group = node['apache']['group'] || web_user
else
  Chef::Log.fatal('Unknown web server option provided for Nagios server: ' \
                  "#{node['nagios']['server']['web_server']} provided. Allowed: 'nginx' or 'apache'")
  fail 'Unknown web server option provided for Nagios server'
end

# use the users_helper.rb library to build arrays of users and contacts
nagios_users = NagiosUsers.new(node)

Chef::Log.fatal("Could not find users in the \"#{node['nagios']['users_databag']}\" databag with the \"#{node['nagios']['users_databag_group']}\"" \
                ' group. Users must be defined to allow for logins to the UI. Make sure the databag exists and, if you have set the ' \
                "\"users_databag_group\", that users in that group exist.") if nagios_users.users.empty?

# configure the appropriate authentication method for the web server
case node['nagios']['server_auth_method']
when 'openid'
  if node['nagios']['server']['web_server'] == 'apache'
    include_recipe 'apache2::mod_auth_openid'
  else
    Chef::Log.fatal('OpenID authentication for Nagios is not supported on NGINX')
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your Nagios role")
    fail
  end
when 'cas'
  if node['nagios']['server']['web_server'] == 'apache'
    include_recipe 'apache2::mod_auth_cas'
  else
    Chef::Log.fatal('CAS authentication for Nagios is not supported on NGINX')
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your Nagios role")
    fail
  end
when 'ldap'
  if node['nagios']['server']['web_server'] == 'apache'
    include_recipe 'apache2::mod_authnz_ldap'
  else
    Chef::Log.fatal('LDAP authentication for Nagios is not supported on NGINX')
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your Nagios role")
    fail
  end
else
  # setup htpasswd auth
  directory node['nagios']['conf_dir']

  template "#{node['nagios']['conf_dir']}/htpasswd.users" do
    source 'htpasswd.users.erb'
    owner node['nagios']['user']
    group web_group
    mode '0640'
    variables(:nagios_users => nagios_users.users)
  end
end

# Setting all general options
unless node['nagios'].nil?
  unless node['nagios']['server'].nil?
    Nagios.instance.normalize_hostname = node['nagios']['server']['normalize_hostname']
  end
end

Nagios.instance.host_name_attribute = node['nagios']['host_name_attribute']

# loading all databag configurations
if node['nagios']['server']['load_databag_config']
  include_recipe 'nagios::_load_databag_config'
end

# loading default configuration data
if node['nagios']['server']['load_default_config']
  include_recipe 'nagios::_load_default_config'
end

directory "#{node['nagios']['conf_dir']}/dist" do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode '0755'
end

directory node['nagios']['state_dir'] do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode '0751'
end

directory "#{node['nagios']['state_dir']}/rw" do
  owner node['nagios']['user']
  group web_group
  mode '2710'
end

execute 'archive-default-nagios-object-definitions' do
  command "mv #{node['nagios']['config_dir']}/*_#{node['nagios']['server']['name']}*.cfg #{node['nagios']['conf_dir']}/dist"
  not_if { Dir.glob("#{node['nagios']['config_dir']}/*_#{node['nagios']['server']['name']}*.cfg").empty? }
end

directory "#{node['nagios']['conf_dir']}/certificates" do
  owner web_user
  group web_group
  mode '0700'
end

bash 'Create SSL Certificates' do
  cwd "#{node['nagios']['conf_dir']}/certificates"
  code <<-EOH
  umask 077
  openssl genrsa 2048 > nagios-server.key
  openssl req -subj "#{node['nagios']['ssl_req']}" -new -x509 -nodes -sha1 -days 3650 -key nagios-server.key > nagios-server.crt
  cat nagios-server.key nagios-server.crt > nagios-server.pem
  EOH
  not_if { ::File.exist?(node['nagios']['ssl_cert_file']) }
end

nagios_conf node['nagios']['server']['name'] do
  config_subdir false
  source 'nagios.cfg.erb'
  variables(:nagios_config => node['nagios']['conf'])
end

nagios_conf 'cgi' do
  config_subdir false
  variables(:nagios_service_name => nagios_service_name)
end

# Update all items before writing the templates
nagios_resourcelist_items 'update'

# resource.cfg differs on RPM and tarball based systems
if node['platform_family'] == 'rhel' || node['platform_family'] == 'fedora'
  template "#{node['nagios']['resource_dir']}/resource.cfg" do
    source 'resource.cfg.erb'
    owner node['nagios']['user']
    group node['nagios']['group']
    mode '0600'
  end

  directory node['nagios']['resource_dir'] do
    owner 'root'
    group node['nagios']['group']
    mode '0755'
  end
end

nagios_conf 'timeperiods'
nagios_conf 'contacts'
nagios_conf 'commands'
nagios_conf 'hosts'
nagios_conf 'hostgroups'
nagios_conf 'templates'
nagios_conf 'services'
nagios_conf 'servicegroups'
nagios_conf 'servicedependencies'

zap_directory node['nagios']['config_dir'] do
  pattern '*.cfg'
end

service 'nagios' do
  service_name nagios_service_name
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
