#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: server
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

# workaround to allow for a nagios server install from source using the override attribute on debian/ubuntu (COOK-2350)
if platform_family?('debian') && node['nagios']['server']['install_method'] == "source"
  nagios_service_name = "nagios"
else
  nagios_service_name = node['nagios']['server']['service_name']
end

# configure either Apache2 or NGINX
web_srv = node['nagios']['server']['web_server'].to_sym

case web_srv
when :nginx
  Chef::Log.info "Setting up Nagios server via NGINX"
  include_recipe 'nagios::nginx'
  web_user = node["nginx"]["user"]
  web_group = node["nginx"]["group"] || web_user
when :apache
  Chef::Log.info "Setting up Nagios server via Apache2"
  include_recipe 'nagios::apache'
  web_user = node["apache"]["user"]
  web_group = node["apache"]["group"] || web_user
else
  Chef::Log.fatal("Unknown web server option provided for Nagios server: " <<
                  "#{node['nagios']['server']['web_server']} provided. Allowed: :nginx or :apache")
  raise 'Unknown web server option provided for Nagios server'
end

# find nagios web interface users from the users data bag
group = node['nagios']['users_databag_group']
begin
  sysadmins = search(:users, "groups:#{group} NOT action:remove")
rescue Net::HTTPServerException
  Chef::Log.fatal("Could not find appropriate items in the \"users\" databag.  Check to make sure there is a users databag and if you have set the \"users_databag_group\" that users in that group exist")
  raise 'Could not find appropriate items in the "users" databag.  Check to make sure there is a users databag and if you have set the "users_databag_group" that users in that group exist'
end

case node['nagios']['server_auth_method']
when "openid"
  if web_srv == :apache
    include_recipe "apache2::mod_auth_openid"
  else
    Chef::Log.fatal("OpenID authentication for Nagios is not supported on NGINX")
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your role: #{node['nagios']['server_role']}")
    raise
  end
when "cas"
  if web_srv == :apache
    include_recipe "apache2::mod_auth_cas"
  else
    Chef::Log.fatal("CAS authentication for Nagios is not supported on NGINX")
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your role: #{node['nagios']['server_role']}")
    raise
  end
when "ldap"
  if(web_srv == :apache)
    include_recipe "apache2::mod_authnz_ldap"
  else
    Chef::Log.fatal("LDAP authentication for Nagios is not supported on NGINX")
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your role: #{node['nagios']['server_role']}")
    raise
  end
else
  directory node['nagios']['conf_dir']
  template "#{node['nagios']['conf_dir']}/htpasswd.users" do
    source "htpasswd.users.erb"
    owner node['nagios']['user']
    group web_group
    mode 00640
    variables(:sysadmins => sysadmins)
  end
end

# install nagios service either from source of package
include_recipe "nagios::server_#{node['nagios']['server']['install_method']}"

# find nodes to monitor.  Search in all environments if multi_environment_monitoring is enabled
Chef::Log.info("Beginning search for nodes.  This may take some time depending on your node count")
nodes = Array.new
hostgroups = Array.new

if node['nagios']['multi_environment_monitoring']
  nodes = search(:node, "hostname:[* TO *]")
else
  nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")
end

if nodes.empty?
  Chef::Log.info("No nodes returned from search, using this node so hosts.cfg has data")
  nodes << node
end

# Sort by name to provide stable ordering
nodes.sort! {|a,b| a.name <=> b.name }

# maps nodes into nagios hostgroups
service_hosts= Hash.new
search(:role, "*:*") do |r|
  hostgroups << r.name
  nodes.select {|n| n['roles'].include?(r.name) }.each do |n|
    service_hosts[r.name] = n[node['nagios']['host_name_attribute']]
  end
end

# if using multi environment monitoring add all environments to the array of hostgroups
if node['nagios']['multi_environment_monitoring']
  search(:environment, "*:*") do |e|
    hostgroups << e.name
    nodes.select {|n| n.chef_environment == e.name }.each do |n|
      service_hosts[e.name] = n[node['nagios']['host_name_attribute']]
    end
  end
end

# Add all unique platforms to the array of hostgroups
nodes.each do |n|
  if !hostgroups.include?(n['os'])
    hostgroups << n['os']
  end
end

nagios_bags = NagiosDataBags.new
services = nagios_bags.get('nagios_services')
servicegroups = nagios_bags.get('nagios_servicegroups')
templates = nagios_bags.get('nagios_templates')
eventhandlers = nagios_bags.get('nagios_eventhandlers')
unmanaged_hosts = nagios_bags.get('nagios_unmanagedhosts')
serviceescalations = nagios_bags.get('nagios_serviceescalations')
contacts = nagios_bags.get('nagios_contacts')
contactgroups = nagios_bags.get('nagios_contactgroups')

# Add unmanaged host hostgroups to the hostgroups array if they don't already exist
unmanaged_hosts.each do |host|
  host['hostgroups'].each do |hg|
    if !hostgroups.include?(hg)
      hostgroups << hg
    end
  end
end

# Load search defined Nagios hostgroups from the nagios_hostgroups data bag and find nodes
hostgroup_nodes= Hash.new
hostgroup_list = Array.new
if nagios_bags.bag_list.include?("nagios_hostgroups")
  search(:nagios_hostgroups, '*:*') do |hg|
    hostgroup_list << hg['hostgroup_name']
    temp_hostgroup_array= Array.new
    if node['nagios']['multi_environment_monitoring']
      search(:node, hg['search_query']) do |n|
        temp_hostgroup_array << n['hostname']
      end
    else
      search(:node, "#{hg['search_query']} AND chef_environment:#{node.chef_environment}") do |n|
        temp_hostgroup_array << n['hostname']
      end
    end
    hostgroup_nodes[hg['hostgroup_name']] = temp_hostgroup_array.join(",")
  end
end

# pick up base contacts
members = Array.new
sysadmins.each do |s|
  members << s['id']
end

public_domain = node['public_domain'] || node['domain']

nagios_conf "nagios" do
  config_subdir false
end

directory "#{node['nagios']['conf_dir']}/dist" do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode 00755
end

directory node['nagios']['state_dir'] do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode 00751
end

directory "#{node['nagios']['state_dir']}/rw" do
  owner node['nagios']['user']
  group web_group
  mode 02710
end

execute "archive-default-nagios-object-definitions" do
  command "mv #{node['nagios']['config_dir']}/*_nagios*.cfg #{node['nagios']['conf_dir']}/dist"
  not_if { Dir.glob("#{node['nagios']['config_dir']}/*_nagios*.cfg").empty? }
end

directory "#{node['nagios']['conf_dir']}/certificates" do
  owner web_user
  group web_group
  mode 00700
end

bash "Create SSL Certificates" do
  cwd "#{node['nagios']['conf_dir']}/certificates"
  code <<-EOH
  umask 077
  openssl genrsa 2048 > nagios-server.key
  openssl req -subj "#{node['nagios']['ssl_req']}" -new -x509 -nodes -sha1 -days 3650 -key nagios-server.key > nagios-server.crt
  cat nagios-server.key nagios-server.crt > nagios-server.pem
  EOH
  not_if { ::File.exists?("#{node['nagios']['ssl_cert_file']}") }
end

%w{ nagios cgi }.each do |conf|
  nagios_conf conf do
    config_subdir false
    variables(:nagios_service_name => nagios_service_name)
  end
end

nagios_conf "timeperiods"

nagios_conf "templates" do
  variables(:templates => templates)
end

nagios_conf "commands" do
  variables(:services => services,
            :eventhandlers => eventhandlers)
end

nagios_conf "services" do
  variables(:service_hosts => service_hosts,
            :services => services,
            :search_hostgroups => hostgroup_list,
            :hostgroups => hostgroups)
end

nagios_conf "servicegroups" do
  variables(:servicegroups => servicegroups)
end

nagios_conf "contacts" do
  variables(:admins => sysadmins,
            :members => members,
            :contacts => contacts,
            :contactgroups => contactgroups,
            :serviceescalations => serviceescalations)
end

nagios_conf "hostgroups" do
  variables(:hostgroups => hostgroups,
            :search_hostgroups => hostgroup_list,
            :search_nodes => hostgroup_nodes)
end

nagios_conf "hosts" do
  variables(:nodes => nodes,
            :unmanaged_hosts => unmanaged_hosts,
            :hostgroups => hostgroups)
end

service "nagios" do
  service_name nagios_service_name
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

# Add the NRPE check to monitor the Nagios server
nagios_nrpecheck "check_nagios" do
  command "#{node['nagios']['plugin_dir']}/check_nagios"
  parameters "-F #{node["nagios"]["cache_dir"]}/status.dat -e 4 -C /usr/sbin/#{nagios_service_name}"
  action :add
end
