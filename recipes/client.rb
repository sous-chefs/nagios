#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: client
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

require 'fileutils'

%w{libdatetime-format-builder-perl libfile-readbackwards-perl}.each do |pkg|
  package pkg do
    action :install
  end
end

mon_host = []

if node.run_list.roles.include?(node['nagios']['server_role'])
  mon_host << node['ipaddress']

  search = "role:openvpn* AND app_environment:#{node['app_environment']} AND placement_availability_zone:#{node['placement_availability_zone']}*"

  search(:node, search) do |vpn_node|
     Chef::Log.warn( "Found node #{vpn_node['ipaddress']}" )
     mon_host << vpn_node['ipaddress']
  end

elsif node['nagios']['multi_environment_monitoring']
  search(:node, "role:#{node['nagios']['server_role']}") do |n|
   mon_host << n['ipaddress']
  end
else
  # Need to add availability zone to the search paramater.
  region = node[:ec2][:placement_availability_zone].match(/^(.*-\d+)[^-]+$/)[1]

  #search = "role:nagios AND app_environment:#{node['app_environment']} AND placement_availability_zone:#{node['placement_availability_zone']}*"
  search = "role:nagios AND placement_availability_zone:#{node['placement_availability_zone']}*"
    Chef::Log.warn( "Searching for Nagios servers -- Search is: #{search}" );
    
 search(:node, search) do |nagios_node|
     Chef::Log.warn( "Found Nagios node #{nagios_node['ipaddress']}" )
     mon_host << nagios_node['ipaddress']
 end

 search_vpns = "role:openvpn* AND placement_availability_zone:#{node['placement_availability_zone']}*"
 Chef::Log.warn( "Searching for VPN servers -- Search is: #{search_vpns}" );

 search(:node, search_vpns) do |vpn_node|
     Chef::Log.warn( "Found VPN node #{vpn_node['ipaddress']}" )
     mon_host << vpn_node['ipaddress']
 end

 #hack for vpn ips (internal, vpn assigned)
 mon_host << "10.8.0.1"
 mon_host << "10.8.0.18"
 mon_host << "10.8.0.22"

 if mon_host.empty?
    search = "role:#{node['nagios']['server_role']} AND app_environment:#{node[:app_environment]} AND placement_availability_zone:#{region}*"
    Chef::Log.warn( "Searching for Nagios Servers -- Search is: #{search}" );
    
   search(:node, search ) do |n|
    Chef::Log.info( "Found node #{n['ipaddress']}" )
    mon_host << n['ipaddress']
   end
 end
 mon_host << node['ipaddress'] if mon_host.empty?

end

include_recipe "nagios::client_#{node['nagios']['client']['install_method']}"

remote_directory node['nagios']['plugin_dir'] do
  source "plugins"
  owner "root"
  group "root"
  mode 00755
  files_mode 00755
end

directory "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d" do
  owner "root"
  group "root"
  mode 00755
end

if node.run_list.roles.include?(node['nagios']['server_role'])
    Chef::Log.warn("Node is a Nagios server")
   
    AZ = node[:ec2][:placement_availability_zone]

    Chef::Log.warn("Availability zone is #{AZ}")
  
    region = node[:ec2][:placement_availability_zone].match(/^(\w{2}).+$/)[1]

    Chef::Log.warn("Country code is #{region}")

      case region
      when "us"
        ntp_server = 'us.pool.ntp.org'
      when "eu"
        ntp_server = 'europe.pool.ntp.org'
      when "ap"
        ntp_server = 'asia.pool.ntp.org'
      when "sa"
        ntp_server = 'south-america.pool.ntp.org'
      else
        Chef::Log.warn("Cannot get country code for server")
      end
else 
    region = node[:ec2][:placement_availability_zone].match(/^(.*-\d+)[^-]+$/)[1]
    #search = "role:#{node['nagios']['server_role']} AND placement_availability_zone:#{region}* AND app_environment:#{node[:app_environment]}"

    #search(:node, search) do |nagios_node|
    #  Chef::Log.warn( "Found Nagios server for NTP at #{nagios_node['ipaddress']}" )
    #  ntp_server =  nagios_node['ipaddress']
    #end   

    #if ntp_server.nil? || ntp_server.empty?
    #get country code for aws instances
    AZ = node[:ec2][:placement_availability_zone]

    Chef::Log.warn("Availability zone is #{AZ}")

    region = node[:ec2][:placement_availability_zone].match(/^(\w{2}).+$/)[1]

    Chef::Log.warn("Country code is #{region}")

      case region
      when "us"
        ntp_server = 'us.pool.ntp.org'
      when "eu"
        ntp_server = 'europe.pool.ntp.org'
      when "ap"
        ntp_server = 'asia.pool.ntp.org'
      when "sa"
        ntp_server = 'south-america.pool.ntp.org'
      else
        Chef::Log.warn("Cannot get country code for server")
      end
   #end
end

if mon_host.nil? || mon_host.empty?
  mon_host = '127.0.0.1'
end

Chef::Log.warn("HERE I AM IN THE RECIPE")

template "#{node['nagios']['nrpe']['conf_dir']}/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "root"
  group "root"
  mode 00644
  variables(
    :mon_host => mon_host,
    :nrpe_directory => "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d",
    :ntp_server => ntp_server
  )
  notifies :restart, "service[nagios-nrpe-server]"
end

service "nagios-nrpe-server" do
  action [:start, :enable]
  supports :restart => true, :reload => true
end

# Use NRPE LWRP to define a few checks
nagios_nrpecheck "check_load" do
  command "#{node['nagios']['plugin_dir']}/check_load"
  warning_condition node['nagios']['checks']['load']['warning']
  critical_condition node['nagios']['checks']['load']['critical']
  action :add
end

if node.roles.include?("server2server")
  nagios_nrpecheck "check_all_disks" do
     command "#{node['nagios']['plugin_dir']}/check_disk"
     warning_condition "8%"
     critical_condition "5%"
     parameters "-W 15 -K 8 -A -x /dev/shm -X nfs -i /boot"
     action :add
  end
elsif node.roles.include?("rabbitmq_server") || node.roles.include?("rabbitmq_server_cluster_disc") || node.roles.include?("rabbitmq_server_cluster_ram")
  nagios_nrpecheck "check_all_disks" do
    command "#{node['nagios']['plugin_dir']}/check_disk"
    warning_condition "15%"
    critical_condition "11%"
    parameters "-W 15 -K 8 -A -x /dev/shm -X nfs -i /boot"
    action :add
  end
else
  nagios_nrpecheck "check_all_disks" do
    command "#{node['nagios']['plugin_dir']}/check_disk"
    warning_condition "8%"
    critical_condition "5%"
    parameters "-W #{node['nagios']['checks']['inode']['warning']} -K #{node['nagios']['checks']['inode']['critical']} -A -x /dev/shm -X nfs -i /boot"
    action :add
  end
end


nagios_nrpecheck "check_users" do
  command "#{node['nagios']['plugin_dir']}/check_users"
  warning_condition "20"
  critical_condition "30"
  action :add
end

include_recipe "nagios::passive_crons"
include_recipe "nagios::sudoers"
include_recipe "nagios::nsca_client"
