#
# Author:: Jake Vanderdray <jvanderdray@customink.com>
# Author:: Tim Smith <tsmith@chef.io>
# Cookbook:: nagios
# Recipe:: pagerduty
#
# Copyright:: 2011, CustomInk LLC
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

include_recipe 'nagios::server_package'

package nagios_pagerduty_packages

remote_file "#{node['nagios']['plugin_dir']}/notify_pagerduty.pl" do
  owner 'root'
  group 'root'
  mode '0755'
  source node['nagios']['pagerduty']['script_url']
  action :create_if_missing
end

template "#{node['nagios']['cgi-bin']}/pagerduty.cgi" do
  source 'pagerduty.cgi.erb'
  owner node['nagios']['user']
  group node['nagios']['group']
  mode '0755'
  variables(
    command_file: node['nagios']['conf']['command_file']
  )
end

nagios_bags = NagiosDataBags.new
pagerduty_contacts = nagios_bags.get('nagios_pagerduty')

nagios_command 'notify-service-by-pagerduty' do
  if node['nagios']['pagerduty']['proxy_url'].nil?
    options 'command_line' => ::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl') + ' enqueue -f pd_nagios_object=service -f pd_description="$HOSTNAME$ : $SERVICEDESC$"'
  else
    options 'command_line' => ::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl') + ' enqueue -f pd_nagios_object=service -f pd_description="$HOSTNAME$ : $SERVICEDESC$"' + " --proxy #{node['nagios']['pagerduty']['proxy_url']}"
  end
end

nagios_command 'notify-host-by-pagerduty' do
  if node['nagios']['pagerduty']['proxy_url'].nil?
    options 'command_line' => ::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl') + ' enqueue -f pd_nagios_object=host -f pd_description="$HOSTNAME$ : $SERVICEDESC$"'
  else
    options 'command_line' => ::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl') + ' enqueue -f pd_nagios_object=host -f pd_description="$HOSTNAME$ : $SERVICEDESC$"' + " --proxy #{node['nagios']['pagerduty']['proxy_url']}"
  end
end

unless node['nagios']['pagerduty']['key'].nil? || node['nagios']['pagerduty']['key'].empty?
  nagios_contact 'pagerduty' do
    options 'alias' => 'PagerDuty Pseudo-Contact',
            'service_notification_period' => '24x7',
            'host_notification_period' => '24x7',
            'service_notification_options' => node['nagios']['pagerduty']['service_notification_options'],
            'host_notification_options' => node['nagios']['pagerduty']['host_notification_options'],
            'service_notification_commands' => 'notify-service-by-pagerduty',
            'host_notification_commands' => 'notify-host-by-pagerduty',
            'pager' => node['nagios']['pagerduty']['key']
  end
end

pagerduty_contacts.each do |contact|
  name = contact['contact'] || contact['id']

  nagios_contact name do
    options 'alias' => "PagerDuty Pseudo-Contact #{name}",
            'service_notification_period' => contact['service_notification_period'] || '24x7',
            'host_notification_period' => contact['host_notification_period'] || '24x7',
            'service_notification_options' => contact['service_notification_options'] || 'w,u,c,r',
            'host_notification_options' => contact['host_notification_options'] || 'd,r',
            'service_notification_commands' => 'notify-service-by-pagerduty',
            'host_notification_commands' => 'notify-host-by-pagerduty',
            'pager' => contact['key'] || contact['pagerduty_key'],
            'contactgroups' => contact['contactgroups']
  end
end

cron 'Flush Pagerduty' do
  user node['nagios']['user']
  mailto 'root@localhost'
  command "#{::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl')} flush"
end
