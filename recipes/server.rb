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

web_srv = node['nagios']['server']['web_server'].to_sym

case web_srv
when :nginx
  Chef::Log.info "Setting up nagios server via NGINX"
  include_recipe 'nagios::nginx'
  web_user = node[:nginx][:user]
  web_group = node[:nginx][:group] || web_user
when :apache
  Chef::Log.info "Setting up nagios server via Apache2"
  include_recipe 'nagios::apache'
  web_user = node[:apache][:user]
  web_group = node[:apache][:group] || web_user
else
  Chef::Log.fatal("Unknown web server option provided for nagios server: " <<
    "#{node['nagios']['server']['web_server']} provided. Allowed: :nginx or :apache"
  )
  raise 'Unknown web server option provided for nagios server'
end

include_recipe "nagios::server_#{node['nagios']['server']['install_method']}"
sysadmins = node['nagios']['sysadmins'] || search(:users, 'groups:sysadmin')


case node['nagios']['server_auth_method']
when "openid"
  if(web_srv == :apache)
    include_recipe "apache2::mod_auth_openid"
  else
    raise "OpenID is not supported on NGINX"
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

sysadmins = node['nagios']['sysadmins'] || search(:users, 'groups:sysadmin')

nodes = node['nagios']['client_addresses'] ||
  search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")

begin
  services = node['nagios']['services'] || search(:nagios_services, '*:*')
rescue Net::HTTPServerException
  Chef::Log.info("Search for nagios_services data bag failed, so we'll just move on.")
end

if services.nil? || services.empty?
  Chef::Log.info("No services returned from data bag search.")
  services = Array.new
end

if nodes.empty?
  Chef::Log.info("No nodes specified, using this node so hosts.cfg has data")
  nodes = Array.new
  nodes << node
end

members = Array.new

sysadmins.each do |s|
  members << s['id']
end

role_list = Array.new
service_hosts= Hash.new

if node['nagios']['hostgroups'].nil?
  search(:role, "*:*") do |r|
    role_list << r.name
    search(:node, "role:#{r.name} AND chef_environment:#{node.chef_environment}") do |n|
      service_hosts[r['name']] = n['hostname']
    end
  end
else
  node['nagios']['hostgroups'].each do |s|
    role_list << s['name']
    s['hosts'].each do |n|
        service_hosts[s['name']] = n['hostname']
    end
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

nagios_conf "commands" do
  variables :services => services
end

nagios_conf "services" do
  variables(
    :service_hosts => service_hosts,
    :services => services
  )
end

nagios_conf "contacts" do
  variables :admins => sysadmins, :members => members
end

nagios_conf "hostgroups" do
  variables :roles => role_list
end

nagios_conf "hosts" do
  variables :nodes => nodes
end

service "nagios" do
  service_name node['nagios']['server']['service_name']
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

nagios_secret = Chef::EncryptedDataBagItem.load_secret(node['nagios']['secretpath'])
nagios_creds = Chef::EncryptedDataBagItem.load('secrets', 's3cfg', nagios_secret)

file nagios_creds['file'] do
  content Base64.decode64(nagios_creds['content'])
  owner nagios_creds['owner']
  group nagios_creds['group']
  mode nagios_creds['mode']
end
