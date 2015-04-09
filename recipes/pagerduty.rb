#
# Author:: Jake Vanderdray <jvanderdray@customink.com>
# Author:: Tim Smith <tim@cozy.co>
# Cookbook Name:: nagios
# Recipe:: pagerduty
#
# Copyright 2011, CustomInk LLC
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

# TODO: remove when backward compatibility is dropped.
def using_old_pagerduty_key_attribute?
  node['nagios']['pagerduty_key'] &&
    node['nagios']['pagerduty_key'] != node['nagios']['pagerduty']['key']
end

if using_old_pagerduty_key_attribute?
  Chef::Log.warn('The nagios.pagerduty_key attribute is deprecated. It is replaced by the nagios.pagerduty.key attribute.')
  Chef::Log.warn('Assigning nagios.pagerduty.key from nagios.pagerduty_key now.')
  node.set['nagios']['pagerduty']['key'] = node['nagios']['pagerduty_key']
end

package 'libwww-perl' do
  case node['platform_family']
  when 'rhel', 'fedora'
    package_name 'perl-libwww-perl'
  when 'debian'
    package_name 'libwww-perl'
  when 'arch'
    package_name 'libwww-perl'
  end
  action :install
end

package 'libcrypt-ssleay-perl' do
  case node['platform_family']
  when 'rhel', 'fedora'
    package_name 'perl-Crypt-SSLeay'
  when 'debian'
    package_name 'libcrypt-ssleay-perl'
  when 'arch'
    package_name 'libcrypt-ssleay-perl'
  end
  action :install
end

remote_file "#{node['nagios']['plugin_dir']}/notify_pagerduty.pl" do
  owner 'root'
  group 'root'
  mode '0755'
  source node['nagios']['pagerduty']['script_url']
  action :create_if_missing
end

nagios_bags = NagiosDataBags.new
pagerduty_contacts = nagios_bags.get('nagios_pagerduty')

nagios_command 'notify-service-by-pagerduty' do
  options 'command_line' => ::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl') + ' enqueue -f pd_nagios_object=service'
end

nagios_command 'notify-service-by-pagerduty' do
  options 'command_line' => ::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl') + ' enqueue -f pd_nagios_object=service'
end

nagios_command 'notify-host-by-pagerduty' do
  options 'command_line' => ::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl') + ' enqueue -f pd_nagios_object=host'
end

unless node['nagios']['pagerduty']['key'].nil? || node['nagios']['pagerduty']['key'].empty?
  nagios_contact 'pagerduty' do
    options 'alias'                         => 'PagerDuty Pseudo-Contact',
            'service_notification_period'   => '24x7',
            'host_notification_period'      => '24x7',
            'service_notification_options'  => node['nagios']['pagerduty']['service_notification_options'],
            'host_notification_options'     => node['nagios']['pagerduty']['host_notification_options'],
            'service_notification_commands' => 'notify-service-by-pagerduty',
            'host_notification_commands'    => 'notify-host-by-pagerduty',
            'pager'                         => node['nagios']['pagerduty']['key']
  end
end

pagerduty_contacts.each do |contact|
  name = contact['contact'] || contact['id']
  nagios_contact name do
    options 'alias'                         => "PagerDuty Pseudo-Contact #{name}",
            'service_notification_period'   => contact['service_notification_period'] || '25x7',
            'host_notification_period'      => contact['host_notification_period'] || '24x7',
            'service_notification_options'  => contact['service_notification_options'] || 'w,u,c,r',
            'host_notification_options'     => contact['host_notification_options'] || 'd,r',
            'service_notification_commands' => 'notify-service-by-pagerduty',
            'host_notification_commands'    => 'notify-host-by-pagerduty',
            'pager'                         => contact['key'] || contact['pagerduty_key']
  end
end

cron 'Flush Pagerduty' do
  user node['nagios']['user']
  mailto 'root@localhost'
  command "#{::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl')} flush"
end
