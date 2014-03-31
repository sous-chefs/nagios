#
# Author:: Jack Jacobs <devops@tealium.com>
# Cookbook Name:: nagios
# Recipe:: passive_crons
#
# Copyright 2013, Tealium Inc.
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

nagios_server = ""
search = "role:#{node['nagios']['server_role']} AND domain:#{node[:domain]}*"
search(:node, search) do |nagios_node|
  Chef::Log.warn( "Found Nagios server for at #{nagios_node['ipaddress']}" )
  nagios_server =  nagios_node['ipaddress']
end

#if node.recipes.include?("uconnect::s2s_logger_plenv") && node[:tealium][:use_nagios] == true
if node.recipes.include?("uconnect::s2s_logger_plenv") || node.roles.include?("uconnect_logger")
  nodesize = node[:ec2][:instance_type].split('.').last
  num_procs = node[:uconnect][:iron_processes][nodesize]
  Chef::Log.warn( "Node is #{nodesize}, and so num of procs is #{num_procs}" )
    for i in 1..num_procs
      template "/var/log/upstart/s2s-httpd-iron-processor-#{i}.log" do
        source "iron_processor.erb"
        owner "root"
        group "root"
        mode 0644
        action :create_if_missing
      end

      cron "Check Rabbit Auth #{i}" do
        minute "*/15"
        command "/bin/sleep `/usr/bin/expr $RANDOM \\% 90` &> /dev/null ; /usr/lib/nagios/plugins/check_log3_passive.pl -l /var/log/upstart/s2s-httpd-iron-processor-#{i}.log -S 'Check Uconnect Rabbit Authentication#{i} AUTO' -s /tmp/rabbit_auth#{i} -p 'Connection reset by peer' -c 1 > /dev/null"
      end

      cron "Check Rabbit Connection #{i}" do
        minute "*/15"
        command "/bin/sleep `/usr/bin/expr $RANDOM \\% 90` &> /dev/null ; /usr/lib/nagios/plugins/check_log3_passive.pl -l /var/log/upstart/s2s-httpd-iron-processor-#{i}.log -S 'Check Uconnect Rabbit Connection#{i} AUTO' -s /tmp/rabbit_connection#{i} -p couldn\\'t connect to server -c 1 > /dev/null"
      end
    end

      cron "Check Uconnect Logs" do
        minute "*/15"
        command "/bin/sleep `/usr/bin/expr $RANDOM \\% 90` &> /dev/null ; /usr/lib/nagios/plugins/Check_Uconnect_Logs.sh"
      end

      template "/usr/lib/nagios/plugins/Check_Uconnect_Logs.sh" do
        source "check_uconnect_logs.sh.erb"
        owner "root"
        group "root"
        mode 0755
      end

      template "/usr/lib/nagios/plugins/check_log3_passive.pl" do
        source "check_log3_passive.pl.erb"
        owner "root"
        group "root"
        mode 0755
        variables(
          :nagios_server => nagios_server
        )
      end
end

if node.roles.include?("hostname_eventstream") && node[:tealium][:use_nagios] == true
  cron "Check Eventstream Logs" do
    minute "*/15"
    command "/bin/sleep `/usr/bin/expr $RANDOM \\% 90` &> /dev/null ; /usr/lib/nagios/plugins/Check_Eventstream_Logs.sh"
    #minute "0"
    #hour "20"
    #day "1"
    #month "11"
    #command "/usr/lib/nagios/plugins/Check_Eventstream_Logs.sh"
  end

  template "/usr/lib/nagios/plugins/Check_Eventstream_Logs.sh" do
    source "check_eventstream_logs.sh.erb"
    owner "root"
    group "root"
    mode 0755
  end

  template "/usr/lib/nagios/plugins/check_log3_passive.pl" do
    source "check_log3_passive.pl.erb"
    owner "root"
    group "root"
    mode 0755
    variables(
      :nagios_server => nagios_server
    )
  end
end

#if node.roles.include?("uconnect_logger") && node[:tealium][:use_nagios] == true
#
#      cron "Check Rabbit Authentication" do
#        minute "*/15"
#        command "/bin/sleep `/usr/bin/expr $RANDOM \\% 90` &> /dev/null ; /usr/lib/nagios/plugins/check_log3_passive.pl -l #{node['nagios']['logfiles']['uconnect']['log_file']} -S 'Check Uconnect Rabbit Authentication' -s /tmp/rabbit_auth -p '#{node['nagios']['checks']['rabbit_auth']['pattern']}' -c 1 > /dev/null"
#      end
#
#      cron "Check Rabbit Connection" do
#        minute "*/15"
#        command "/bin/sleep `/usr/bin/expr $RANDOM \\% 90` &> /dev/null ; /usr/lib/nagios/plugins/check_log3_passive.pl -l #{node['nagios']['logfiles']['uconnect']['log_file']} -S 'Check Uconnect Rabbit Connection' -s /tmp/rabbit_connection -p #{node['nagios']['checks']['rabbit_connection']['pattern']} -c 1 > /dev/null"
#      end
#
#      template "/usr/lib/nagios/plugins/check_log3_passive.pl" do
#        source "check_log3_passive.pl.erb"
#        owner "root"
#        group "root"
#        mode 0755
#        variables(
#        :nagios_server => nagios_server
#        )
#      end
#end

if node.roles.include?("utui")
 
  Chef::Log.warn( "Node roles are #{node.roles}.")
 
  cron "Check UTUI Logs" do
    minute "*/15"
    command "/bin/sleep `/usr/bin/expr $RANDOM \\% 90` &> /dev/null ; /usr/lib/nagios/plugins/Check_UTUI_Logs.sh"
  end

  template "/usr/lib/nagios/plugins/Check_UTUI_Logs.sh" do
    source "check_utui_logs.sh.erb"
    owner "root"
    group "root"
    mode 0755
  end

  template "/usr/lib/nagios/plugins/check_log3_passive.pl" do
    source "check_log3_passive.pl.erb"
    owner "root"
    group "root"
    mode 0755
    variables(
      :nagios_server => "10.168.13.173"
    )
  end
end
