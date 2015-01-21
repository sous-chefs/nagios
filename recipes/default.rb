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
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your role: #{node['nagios']['server_role']}")
    fail
  end
when 'cas'
  if node['nagios']['server']['web_server'] == 'apache'
    include_recipe 'apache2::mod_auth_cas'
  else
    Chef::Log.fatal('CAS authentication for Nagios is not supported on NGINX')
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your role: #{node['nagios']['server_role']}")
    fail
  end
when 'ldap'
  if node['nagios']['server']['web_server'] == 'apache'
    include_recipe 'apache2::mod_authnz_ldap'
  else
    Chef::Log.fatal('LDAP authentication for Nagios is not supported on NGINX')
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your role: #{node['nagios']['server_role']}")
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

# find nodes to monitor.  Search in all environments if multi_environment_monitoring is enabled
Chef::Log.info('Beginning search for nodes.  This may take some time depending on your node count')
nodes = []
excluded_nodes = []
hostgroups = []
multi_env = node['nagios']['monitored_environments']
multi_env_search = multi_env.empty? ? '' : ' AND (chef_environment:' + multi_env.join(' OR chef_environment:') + ')'
exclusion_tag = node['nagios']['exclude_tag_host']

if node['nagios']['multi_environment_monitoring']
  search(:node, "name:*#{multi_env_search}").each do |all_nodes|
    if all_nodes.key?('tags') && all_nodes['tags'].include?(exclusion_tag)
      excluded_nodes << all_nodes[node['nagios']['host_name_attribute']]
    else
      nodes << all_nodes
    end
  end
else
  search(:node, "name:* AND chef_environment:#{node.chef_environment}").each do |all_nodes|
    if all_nodes.key?('tags') && all_nodes['tags'].include?(exclusion_tag)
      excluded_nodes << all_nodes[node['nagios']['host_name_attribute']]
    else
      nodes << all_nodes
    end
  end
end

if nodes.empty?
  Chef::Log.info('No nodes returned from search, using this node so hosts.cfg has data')
  nodes << node
end

# Sort by name to provide stable ordering
nodes.sort! { |a, b| a.name <=> b.name }

# maps nodes into nagios hostgroups
service_hosts = {}
search(:role, '*:*') do |r|
  hostgroups << r.name
  nodes.select { |n| n['roles'].include?(r.name) if n['roles'] }.each do |n|
    service_hosts[r.name] = n[node['nagios']['host_name_attribute']]
  end
end

# if using multi environment monitoring add all environments to the array of hostgroups
if node['nagios']['multi_environment_monitoring']
  search(:environment, '*:*') do |e|
    hostgroups << e.name unless hostgroups.include?(e.name)
    nodes.select { |n| n.chef_environment == e.name }.each do |n|
      service_hosts[e.name] = n[node['nagios']['host_name_attribute']]
    end
  end
end

# Add all unique platforms to the array of hostgroups
nodes.each do |n|
  hostgroups << n['os'] unless hostgroups.include?(n['os']) || n['os'].nil?
end

# Hack to deal with the nagios server being the first linux system
hostgroups << node['os'] unless hostgroups.include?(node['os']) || node['os'].nil?

nagios_bags         = NagiosDataBags.new
services            = nagios_bags.get(node['nagios']['services_databag'])
servicegroups       = nagios_bags.get(node['nagios']['servicegroups_databag'])
templates           = nagios_bags.get(node['nagios']['templates_databag'])
hosttemplates           = nagios_bags.get(node['nagios']['hosttemplates_databag'])
eventhandlers       = nagios_bags.get(node['nagios']['eventhandlers_databag'])
unmanaged_hosts     = nagios_bags.get(node['nagios']['unmanagedhosts_databag'])
serviceescalations  = nagios_bags.get(node['nagios']['serviceescalations_databag'])
hostescalations     = nagios_bags.get(node['nagios']['hostescalations_databag'])
contacts            = nagios_bags.get(node['nagios']['contacts_databag'])
contactgroups       = nagios_bags.get(node['nagios']['contactgroups_databag'])
servicedependencies = nagios_bags.get(node['nagios']['servicedependencies_databag'])
timeperiods         = nagios_bags.get(node['nagios']['timeperiods_databag'])

# Add unmanaged host hostgroups to the hostgroups array if they don't already exist
unmanaged_hosts.each do |host|
  host['hostgroups'].each do |hg|
    hostgroups << hg unless hostgroups.include?(hg)
  end
end

# Load search defined Nagios hostgroups from the nagios_hostgroups data bag and find nodes
hostgroup_nodes = {}
hostgroup_list = []
if nagios_bags.bag_list.include?('nagios_hostgroups')
  search(:nagios_hostgroups, '*:*') do |hg|
    hostgroup_list << hg['hostgroup_name']
    temp_hostgroup_array = Array.new
    if node['nagios']['multi_environment_monitoring']
      search(:node, hg['search_query']) do |n|
        unless excluded_nodes.include?(n[node['nagios']['host_name_attribute']])
          temp_hostgroup_array << n[node['nagios']['host_name_attribute']]
        end
      end
    else
      search(:node, "#{hg['search_query']} AND chef_environment:#{node.chef_environment}") do |n|
        unless excluded_nodes.include?(n[node['nagios']['host_name_attribute']])
          temp_hostgroup_array << n[node['nagios']['host_name_attribute']]
        end
      end
    end
    hostgroup_nodes[hg['hostgroup_name']] = temp_hostgroup_array.join(',')
    hostgroup_nodes[hg['hostgroup_name']].downcase! if node['nagios']['server']['normalize_hostname']
  end
end

directory "#{node['nagios']['conf_dir']}/dist" do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode '0755'
end

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
  variables(:nagios_service_name => nagios_service_name)
end

nagios_conf 'cgi' do
  config_subdir false
  variables(:nagios_service_name => nagios_service_name)
end

nagios_conf 'timeperiods' do
  variables(:timeperiods => timeperiods)
end

nagios_conf 'templates' do
  variables(:templates => templates,
            :hosttemplates => hosttemplates)
end

nagios_conf 'commands' do
  variables(:services => services,
            :eventhandlers => eventhandlers)
end

nagios_conf 'services' do
  variables(:services => services,
            :search_hostgroups => hostgroup_list,
            :hostgroups => hostgroups)
end

nagios_conf 'servicegroups' do
  variables(:servicegroups => servicegroups)
end

nagios_conf 'contacts' do
  variables(:admins => nagios_users.users,
            :members => nagios_users.return_user_contacts,
            :contacts => contacts,
            :contactgroups => contactgroups,
            :serviceescalations => serviceescalations,
            :hostescalations => hostescalations)
end

nagios_conf 'hostgroups' do
  variables(:hostgroups => hostgroups,
            :search_hostgroups => hostgroup_list,
            :search_nodes => hostgroup_nodes)
end

nagios_conf 'hosts' do
  variables(:nodes => nodes,
            :unmanaged_hosts => unmanaged_hosts,
            :hostgroups => hostgroups)
end

nagios_conf 'servicedependencies' do
  variables(:servicedependencies => servicedependencies)
end

service 'nagios' do
  service_name nagios_service_name
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
