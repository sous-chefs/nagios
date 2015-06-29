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

if node.roles.include?("utui")
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
      :nagios_server => "10.250.168.137"
    )
  end
end

if node.roles.include?("sitescan_sitemap") || node.roles.include?("sitescan_urls")
  cron "Check SiteMap Logs" do
    minute "*/15"
    command "/bin/sleep `/usr/bin/expr $RANDOM \\% 90` &> /dev/null ; /usr/lib/nagios/plugins/Check_Sitemap_Logs.sh"
  end

  template "/usr/lib/nagios/plugins/Check_Sitemap_Logs.sh" do
    source "check_sitemap_logs.sh.erb"
    owner "root"
    group "root"
    mode 0755
  end

  region = node['ec2']['region']
  nagios_server = "#{node["consul"]["server"][region]}"

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


if node.roles.include?("dc_uconnect")
  cron "Check DC Uconnect Logs" do
    minute "*/15"
    command "/bin/sleep `/usr/bin/expr $RANDOM \\% 90` &> /dev/null ; /usr/lib/nagios/plugins/Check_DC_Uconnect_Logs.sh"
    command "cat /dev/null"

  end

  template "/usr/lib/nagios/plugins/Check_DC_Uconnect_Logs.sh" do
    source "check_dc_uconnect_logs.sh.erb"
    owner "root"
    group "root"
    mode 0755
  end

  region = node['ec2']['region']
  nagios_server = "#{node["consul"]["server"][region]}"

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







