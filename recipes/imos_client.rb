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

# We'll need the perl linux statistics module
package "libsys-statistics-linux-perl" do
  package_name "libsys-statistics-linux-perl"
  action :install
end

# Sync with custom scripts
remote_directory "#{node['nagios']['plugin_dir']}" do
  source "plugins"
  files_owner node['nagios']['user']
  files_group node['nagios']['group']
  files_mode 00755
end

# Check for high load.  This check defines warning levels and attributes
nagios_nrpecheck "check_load" do
  command "#{node['nagios']['plugin_dir']}/check_load"
  warning_condition "15,3,1.7"
  critical_condition "15,15,15"
  action :add
end

# Check all non-NFS/tmp-fs disks.
nagios_nrpecheck "check_disks" do
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
  warning_condition "8"
  critical_condition "15"
  action :add
end

# Check number of processes
nagios_nrpecheck "check_total_procs" do
  command "#{node['nagios']['plugin_dir']}/check_procs"
  warning_condition "400"
  critical_condition "600"
  action :add
end

# Check swap
nagios_nrpecheck "check_swap" do
  command "#{node['nagios']['plugin_dir']}/check_swap"
  warning_condition "60"
  critical_condition "10"
  action :add
end

# Check CPU
nagios_nrpecheck "check_cpu" do
  command "#{node['nagios']['plugin_dir']}/check_linux_stats.pl -C -u % -w 100 -c 100"
  action :add
end

# Check memory
nagios_nrpecheck "check_mem" do
  command "#{node['nagios']['plugin_dir']}/check_linux_stats.pl -M -u % -c 90,100 -w 95,100"
  action :add
end

# Check disk IO
nagios_nrpecheck "check_disk_io" do
  command "#{node['nagios']['plugin_dir']}/check_linux_stats.pl -I -u BYTES -w 34816000,34816000 -c 43008000,43008000"
  action :add
end

# Check network
nagios_nrpecheck "check_net" do
  command "#{node['nagios']['plugin_dir']}/check_linux_stats.pl -N -u KB -w 50000 -c 60000"
  action :add
end

# Check for pgsql
if node['postgresql'] and node['postgresql']['config']
  # 2013-07-19 - no databases defined, we will only use the default one (simply
  # run check_pgsql with no database), so we'll inject it!
  # TODO Remove this section once databases are defined in node definitions
  node_databases = []
  node_databases.push(node['postgresql']['databases'])
  # Push the dummy database
  node_databases.push({ "name" => "" })
  if node_databases
    node_databases.each do |pgsql_database|
      if pgsql_database
        db_name = pgsql_database['name']
        # define nrpe check
        nagios_nrpecheck "check_pgsql_#{db_name}" do
          command "sudo -u postgres #{node['nagios']['plugin_dir']}/check_pgsql"
          action :add
        end
      end
    end
  end

  # check_pgsql will need sudo access as user postgres
  sudo "nagios_postgres" do
    user node['nagios']['user']
    runas "postgres"
    commands [ "#{node['nagios']['plugin_dir']}/check_pgsql" ] 
    host "ALL"
    nopasswd true
  end
end

# Check all IMOS tomcat instances
if node['tomcat'] and node['tomcat']['instances']
  node['tomcat']['instances'].each do |tomcat_instance|
    instance_name = tomcat_instance['name']
    instance_port = tomcat_instance['ports']['connector_port'] ? tomcat_instance['ports']['connector_port'] : 8080
    # Make sure it's an actual tomcat instance and not the stub one taken
    # from the cookbook's attributes
    if instance_name != "default" and instance_port != "8080"
      nagios_nrpecheck "check_tomcat_#{instance_port}" do
        command "#{node['nagios']['plugin_dir']}/check_http -H localhost -p #{instance_port}"
        action :add
      end
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

