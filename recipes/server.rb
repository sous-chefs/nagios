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
    "#{node['nagios']['server']['web_server']} provided. Allowed: :nginx or :apache"
  )
  raise 'Unknown web server option provided for Nagios server'
end

# install nagios service either from source of package
include_recipe "nagios::server_#{node['nagios']['server']['install_method']}"

group = "#{node['nagios']['users_databag_group']}"
sysadmins = search(:users, "groups:#{group}")

case node['nagios']['server_auth_method']
when "openid"
  if(web_srv == :apache)
    include_recipe "apache2::mod_auth_openid"
  else
    Chef::Log.fatal("OpenID authentication for Nagios is not supported on NGINX")
    Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your role: #{node['nagios']['server_role']}")
    raise
  end
else
  template "#{node['nagios']['conf_dir']}/htpasswd.users" do
    source "htpasswd.users.erb"
    owner node['nagios']['user']
    group web_group
    mode 00640
    variables(
      :sysadmins => sysadmins
    )
  end
end

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
    service_hosts[r.name] = n['hostname']
  end
end

# if using multi environment monitoring add all environments to the array of hostgroups
if node['nagios']['multi_environment_monitoring']
  search(:environment, "*:*") do |e|
    hostgroups << e.name
    nodes.select {|n| n.chef_environment == e.name }.each do |n|
      service_hosts[e.name] = n['hostname']
    end
  end
end

# Add all unique platforms to the array of hostgroups
nodes.each do |n|
  if !hostgroups.include?(n['os'])
    hostgroups << n['os']
  end
end

# load Nagios services from the nagios_services data bag
begin
  services = search(:nagios_services, '*:*')
rescue Net::HTTPServerException
  Chef::Log.info("Could not search for nagios_service data bag items, skipping dynamically generated service checks")
end

if services.nil? || services.empty?
  Chef::Log.info("No services returned from data bag search.")
  services = Array.new
end

# Load Nagios templates from the nagios_templates data bag
begin
  templates = search(:nagios_templates, '*:*')
  rescue Net::HTTPServerException
  Chef::Log.info("Could not search for nagios_template data bag items, skipping dynamically generated template checks")
end

if templates.nil? || templates.empty?
  Chef::Log.info("No templates returned from data bag search.")
  templates = Array.new
end

# Load Nagios event handlers from the nagios_eventhandlers data bag
begin
  eventhandlers = search(:nagios_eventhandlers, '*:*')
rescue Net::HTTPServerException
  Chef::Log.info("Search for nagios_eventhandlers data bag failed, so we'll just move on.")
end

if eventhandlers.nil? || eventhandlers.empty?
  Chef::Log.info("No Event Handlers returned from data bag search.")
  eventhandlers = Array.new
end

# find all unique hostgroups in the nagios_unmanagedhosts data bag
begin
  unmanaged_hosts = search(:nagios_unmanagedhosts, '*:*')
rescue Net::HTTPServerException
  Chef::Log.info("Search for nagios_unmanagedhosts data bag failed, so we'll just move on.")
end

# Add unmanaged host hostgroups to the hostgroups array if they don't already exist
if unmanaged_hosts.nil? || unmanaged_hosts.empty?
  Chef::Log.info("No unmanaged hosts returned from data bag search.")
else
  unmanaged_hosts.each do |host|
    host['hostgroups'].each do |hg|
      if !hostgroups.include?(hg)
        hostgroups << hg
      end
    end
  end
end

# Load search defined Nagios hostgroups from the nagios_hostgroups data bag and find nodes
begin
  hostgroup_nodes= Hash.new
  hostgroup_list = Array.new
  search(:nagios_hostgroups, '*:*') do |hg|
    hostgroup_list << hg['hostgroup_name']
    temp_hostgroup_array= Array.new
    search(:node, "#{hg['search_query']}") do |n|
      temp_hostgroup_array << n['hostname']
    end
    hostgroup_nodes[hg['hostgroup_name']] = temp_hostgroup_array.join(",")
  end
rescue Net::HTTPServerException
  Chef::Log.info("Search for nagios_hostgroups data bag failed, so we'll just move on.")
end

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
  not_if { ::File.exists?("#{node['nagios']['conf_dir']}/certificates/nagios-server.pem") }
end

%w{ nagios cgi }.each do |conf|
  nagios_conf conf do
    config_subdir false
  end
end

nagios_conf "timeperiods"

nagios_conf "templates" do
    variables :templates => templates
end

nagios_conf "commands" do
  variables(
    :services => services,
    :eventhandlers => eventhandlers
  )
end

nagios_conf "services" do
  variables(
    :service_hosts => service_hosts,
    :services => services,
    :hostgroups => hostgroups
  )
end

nagios_conf "contacts" do
  variables :admins => sysadmins, :members => members
end

nagios_conf "hostgroups" do
  variables(
    :hostgroups => hostgroups,
    :search_hostgroups => hostgroup_list,
    :search_nodes => hostgroup_nodes
  )
end

nagios_conf "hosts" do
  variables(
    :nodes => nodes,
    :unmanaged_hosts => unmanaged_hosts,
    :hostgroups => hostgroups
  )
end

service "nagios" do
  service_name node['nagios']['server']['service_name']
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

# Add the NRPE check to monitor the Nagios server
nagios_nrpecheck "check_nagios" do
  command "#{node['nagios']['plugin_dir']}/check_nagios"
  parameters "-F #{node["nagios"]["cache_dir"]}/status.dat -e 4 -C /usr/sbin/#{node['nagios']['server']['service_name']}"
  action :add
end
