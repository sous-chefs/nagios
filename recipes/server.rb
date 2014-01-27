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

  include_recipe "java"

include_recipe "perl"
include_recipe "zookeeper_tealium::client_python"
include_recipe "tealium_bongo::packages"
include_recipe "pnp4nagios_tealium"
include_recipe "nagios::nsca_server"

%w{make libnet-nslookup-perl libmodule-install-perl libyaml-perl libyaml-syck-perl libwww-perl libnagios-plugin-perl}.each do |pkg|
  package pkg do
    action :install
  end
end

[
  "LWP::UserAgent::DNS::Hosts"
].each { |package|
   cpan_module package
}

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

# Install nagios either from source of package
include_recipe "nagios::server_#{node['nagios']['server']['install_method']}"

sysadmins = search(:users, 'groups:sysadmin')

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
    mode 0640
    variables(
      :sysadmins => sysadmins
    )
  end
end

  directory "#{node['nagios']['docroot_pub']}" do
    owner node['nagios']['user']
    group node['nagios']['group']
    mode 00755
  end

  template "#{node['nagios']['docroot_pub']}/index.html" do
    source "index.html.erb"
    owner node['nagios']['user']
    group web_group
    mode 0644
  end
 
region = node[:ec2][:placement_availability_zone].match(/^(.*-\d+)[^-]+$/)[1]

if node[:monitored_region].nil? 
  nodes = search(:node, "hostname:[* TO *] AND app_environment:#{node[:app_environment]} AND placement_availability_zone:#{region}* AND tealium_use_nagios:true")
else

  #nodes1 = search(:node, "domain:prod* AND app_environment:production* AND placement_availability_zone:#{region}*")
  nodes1 = search(:node, "domain:prod* AND app_environment:production* AND placement_availability_zone:#{region}* AND tealium_use_nagios:true")
 
  nodes = []
  nodes1.each do |n|
    if n.roles.include?("base")
      nodes << n
    end
  end
 
  #nodes = search(:node, "hostname:[* TO *] AND app_environment:#{node[:app_environment]} AND placement_availability_zone:#{region}*")
  ##nodes = search(:node, "hostname:[* TO *] AND app_environment:#{node[:monitored_environment]} AND placement_availability_zone:#{node[:monitored_region]}*")
end

if nodes.empty?
  Chef::Log.warn("No nodes returned from search, using this node so hosts.cfg has data")
  nodes = Array.new
  nodes << node
end

# find all unique platforms to create hostgroups
os_list = Array.new

nodes.each do |n|
	if !os_list.include?(n['os'])
		os_list << n['os']
	end
end

# Load Nagios services from the nagios_services data bag
begin
  services = search(:nagios_services, '*:*')
rescue Net::HTTPServerException
  Chef::Log.info("Could not search for nagios_service data bag items, skipping dynamically generated service checks")
end

if services.nil? || services.empty?
  Chef::Log.info("No services returned from data bag search.")
  services = Array.new
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

# maps nodes into nagios hostgroups
role_list = Array.new
service_hosts= Hash.new
search(:role, "*:*") do |r|
  role_list << r.name
  search(:node, "role:#{r.name} AND app_environment:#{node[:app_environment]}") do |n|
    service_hosts[r.name] = n['hostname']
  end
end

if node['public_domain']
  public_domain = node['public_domain']
else
  public_domain = node['domain']
end


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

%w{ templates timeperiods}.each do |conf|
  nagios_conf conf
end

domain = node[:domain]

case domain
when "prod1.us-w1"
  url = "us-west-1-vpc.nagios.ops.tlium.com/nagios3/"
when "prod1.us-e1"
  url = "us-east-1-vpc.nagios.ops.tlium.com/nagios3/"
when "prod1.eu-w1"
  url = "eu-west-1-vpc.nagios.ops.tlium.com/nagios3/"
when "us-west-1.compute.internal"
  url = "us-west-1.nagios.ops.tlium.com/nagios3/"
when "eu-w1"
  url = "eu-west-1.nagios.ops.tlium.com/nagios3/"
when "ec2.internal"
  url = "us-east-1.nagios.ops.tlium.com/nagios3/"
end

nagios_conf "commands" do
  variables(
    :services => services,
    :url => url
  )
end

dcvp = search(:node, "role:dc_visitor_processor AND app_environment:production*")
dcmr = search(:node, "role:dc_message_router AND app_environment:production*")
dcqa = search(:node, "role:dc_query_aggregator AND app_environment:production*")
dcdd = search(:node, "role:dc_data_distributor AND app_environment:production*")

if dcvp.empty?
vp_heap = 10
else
vp_heap = dcvp.last[:datacloud][:visitor_processor][:java_options].match(/^\DX{1}[a-z]{2}\d[g]\s\DX{1}[a-z]{2}(\d)[g]/)[1]
end

if dcmr.empty?
mr_heap = 10
else
mr_heap = dcmr.last[:datacloud][:message_router][:java_options].match(/^\DX{1}[a-z]{2}\d{1,3}(m|g)\s\DX{1}[a-z]{2}(\d{1,3})(m|g)/)[2]
end

if dcqa.empty? 
qa_heap = 10
else
qa_heap = dcqa.last[:datacloud][:query_aggregator][:java_options].match(/^\DX{1}[a-z]{2}\d[g]\s\DX{1}[a-z]{2}(\d)[g]/)[1]
end

if dcdd.empty?
dd_heap = 10
else
dd_heap = dcdd.last[:datacloud][:data_distributor][:java_options].match(/^\DX{1}[a-z]{2}\d[g]\s\DX{1}[a-z]{2}(\d)[g]/)[1]
end

if node[:monitored_region].nil?
uconnects = []
else
  uconnects = []
  search = search(:node, "domain:prod* AND app_environment:production* AND placement_availability_zone:#{region}*")
    search.each do |n|
      if n.recipes.include?("uconnect::s2s_logger_plenv")
        uconnects << n
      end
    end
end

Chef::Log.warn("Uconnects are: #{uconnects}")

designation = "host_name"

if node[:ec2][:local_ipv4] == "10.1.2.7"
main_nagios = "#{node['hostname']} - #{node[:ipaddress]}"

  template "/home/ubuntu/nagios" do
    source "nagios.sudoers.erb"
    owner "root"
    group "root"
    mode 0440
  end

  if ::File.exists?('/home/ubuntu/nagios')
    FileUtils.cp('/home/ubuntu/nagios', '/etc/sudoers.d/nagios')
  end  

  nagios_conf "services" do
    variables(
      :service_hosts => service_hosts,
      :services => services,
      :main_nagios => main_nagios,
      :designation => designation,
      :vp_heap => vp_heap,
      :mr_heap => mr_heap,
      :qa_heap => qa_heap,
      :dd_heap => dd_heap,
      :uconnects => uconnects
    )
  end
else
  nagios_conf "services" do
    variables(
      :service_hosts => service_hosts,
      :services => services,
      :vp_heap => vp_heap,
      :mr_heap => mr_heap,
      :qa_heap => qa_heap,
      :dd_heap => dd_heap,
      :uconnects => uconnects,
      :designation => designation
    )
  end
end

nagios_conf "contacts" do
  variables :admins => sysadmins, :members => members
end

nagios_conf "hostgroups" do
  variables(
    :roles => role_list,
    :os => os_list,
    :search_hostgroups => hostgroup_list,
    :search_nodes => hostgroup_nodes
    )
end

nagios_conf "hosts" do
  variables( 
  :nodes => nodes
  )
end

include_recipe "nagios::pagerduty"

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

#include_recipe "nagios::pagerduty"
