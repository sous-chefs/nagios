#
# Cookbook Name:: monitoring
# Recipe:: imos_client
#
# Copyright 2013, Example Company, Inc.
#
# This recipe defines the necessary NRPE commands for base system monitoring
# in Example Company Inc's Chef environment.
#

include_recipe "nagios::client"

# sync with custom scripts
remote_directory "#{node['nagios']['plugin_dir']}" do
  source "plugins"
  files_owner node['nagios']['user']
  files_group node['nagios']['group']
  files_mode 00755
end

# Check for high load.  This check defines warning levels and attributes
nagios_nrpecheck "check_load" do
  command "#{node['nagios']['plugin_dir']}/check_load"
  warning_condition "6"
  critical_condition "10"
  action :add
end

# Check all non-NFS/tmp-fs disks.
nagios_nrpecheck "check_all_disks" do
  command "#{node['nagios']['plugin_dir']}/check_disk"
  warning_condition "8%"
  critical_condition "5%"
  parameters "-A -x /dev/shm -X nfs -i /boot"
  action :add
end

# Check for excessive users.  This command relies on the service definition to
# define what the warning/critical levels and attributes are
nagios_nrpecheck "check_users" do
  command "#{node['nagios']['plugin_dir']}/check_users"
  warning_condition "20"
  critical_condition "40"
  action :add
end

# Check number of processes
nagios_nrpecheck "check_procs" do
  command "#{node['nagios']['plugin_dir']}/check_procs"
  action :add
end

# Check swap
nagios_nrpecheck "check_swap" do
  command "#{node['nagios']['plugin_dir']}/check_swap"
  warning_condition "90"
  critical_condition "70"
  action :add
end

# Check for pgsql
nagios_nrpecheck "check_pgsql" do
  command "#{node['nagios']['plugin_dir']}/check_pgsql"
  warning_condition "20"
  critical_condition "50"
  action :add
end

# Check all IMOS tomcat instances
if node['tomcat'] and node['tomcat']['instances']
  node['tomcat']['instances'].each do |tomcat_instance|
    instance_name = tomcat_instance['name']
    instance_port = tomcat_instance['ports']['connector_port'] ? tomcat_instance['ports']['connector_port'] : 8080
    nagios_nrpecheck "check_tomcat_#{instance_port}" do
      command "#{node['nagios']['plugin_dir']}/check_http -H localhost -P #{instance_port}"
      action :add
    end
  end
end

# Define nrpe checks for mount points
if node['aodn'] and node['aodn']['mount'] and node['aodn']['mount']['mounts']
  node['aodn']['mount']['mounts'].each do |mount_point_entry|
    mount_point            = mount_point_entry['mount_point']
    # Normalize mount point, so we can create a filename with that name
    # /mnt/imos-t4 -> _mnt_imos-t4
    mount_point_normalized = mount_point.gsub(/[\/]/, '_')
    device                 = mount_point_entry['device']
    warning                = mount_point_entry['warning']  ? mount_point_entry['warning']  : "50"
    critical               = mount_point_entry['critical'] ? mount_point_entry['critical'] : "20"
    nagios_nrpecheck "check_disk_#{mount_point_normalized}" do
      command "#{node['nagios']['plugin_dir']}/check_disk -w #{warning} -c #{critical} -p #{mount_point}"
      action :add
    end
  end
end

