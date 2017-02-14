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

region = node['ec2']['placement_availability_zone'].match(/^(\w{2}).+$/)[1]

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

platform_version = node["platform_version"]

template "#{node['nagios']['nrpe']['conf_dir']}/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "root"
  group "root"
  mode 00644
  variables(
    :nrpe_directory => "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d",
    :ntp_server => ntp_server,
    :platform_version => platform_version
  )
  notifies :restart, "service[nagios-nrpe-server]"
end

service "nagios-nrpe-server" do
  action [:start, :enable]
  supports :restart => true, :reload => true
end

# Use NRPE LWRP to define a few checks
if node.roles.include?('mongodb_config')
  nagios_nrpecheck "check_load" do
    command "#{node['nagios']['plugin_dir']}/check_load"
    warning_condition "20,15,8"
    critical_condition node['nagios']['checks']['load']['critical']
    action :add
  end
elsif node.recipes.include?('mongodb::mongos')
  nagios_nrpecheck "check_load" do
    command "#{node['nagios']['plugin_dir']}/check_load"
    warning_condition "20,15,10"
    critical_condition "30,25,20"
    action :add
  end
else
  nagios_nrpecheck "check_load" do
    command "#{node['nagios']['plugin_dir']}/check_load"
    warning_condition node['nagios']['checks']['load']['warning']
    critical_condition node['nagios']['checks']['load']['critical']
    action :add
  end
end

if node.roles.include?('server2server')
  nagios_nrpecheck "check_all_disks" do
     command "#{node['nagios']['plugin_dir']}/check_disk"
     warning_condition "8%"
     critical_condition "5%"
     parameters "-W 15 -K 8 -A -x /dev/shm -X nfs -i /boot"
     action :add
  end
elsif node.roles.include?('mongodb_cluster')
  nagios_nrpecheck "check_all_disks" do
    command "#{node['nagios']['plugin_dir']}/check_disk"
    warning_condition "4%"
    critical_condition "4%"
    parameters "-W 15 -K 8 -A -x /dev/shm -X nfs -i /boot"
    action :add
  end
elsif node.roles.include?('rabbitmq_server') || node.roles.include?('rabbitmq_server_cluster_disc') || node.roles.include?('rabbitmq_server_cluster_ram')
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

#get and set stunnel version
version = `dpkg -s stunnel4 | grep Version | cut -d ' ' -f2 | cut -d : -f2 | cut -d - -f1`
#version = Mixlib::ShellOut.new('dpkg -s stunnel4 | grep Version | cut -d ' ' -f2 | cut -d : -f2 | cut -d - -f1')
#version.run_command
#version.error!
node.set['stunnel']['version'] = version.to_f

include_recipe "nagios::passive_crons"
include_recipe "nagios::sudoers"
include_recipe "nagios::nsca_client"
