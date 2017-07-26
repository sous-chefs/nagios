#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Recipe:: _load_databag_config
#
# Copyright 2014, Sander Botman
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

# Loading all databag information
nagios_bags = NagiosDataBags.new

hostgroups = nagios_bags.get(node['nagios']['hostgroups_databag'])
hostgroups.each do |group|
  next if group['search_query'].nil?
  if node['nagios']['multi_environment_monitoring']
    query_environments = node['nagios']['monitored_environments'].map do |environment|
      "chef_environment:#{environment}"
    end.join(' OR ')
    result = search(:node, "(#{group['search_query']}) AND (#{query_environments})")
  else
    result = search(:node, "#{group['search_query']} AND chef_environment:#{node.chef_environment}")
  end

  result.each do |n|
    n.automatic_attrs['roles'] = [group['hostgroup_name']]
    Nagios.instance.push(n)
  end
end

services = nagios_bags.get(node['nagios']['services_databag'])
services.each do |item|
  next unless item['activate_check_in_environment'].nil? || item['activate_check_in_environment'].include?(node.chef_environment)
  name = item['service_description'] || item['id']
  check_command = name.downcase.start_with?('check_') ? name.downcase : 'check_' + name.downcase
  command_name = item['check_command'].nil? ? check_command : item['check_command']
  service_name = name.downcase.start_with?('check_') ? name.gsub('check_', '') : name.downcase
  item['check_command'] = command_name

  nagios_command command_name do
    options item
  end

  nagios_service service_name do
    options item
  end
end

contactgroups = nagios_bags.get(node['nagios']['contactgroups_databag'])
contactgroups.each do |item|
  name = item['contactgroup_name'] || item['id']
  nagios_contactgroup name do
    options item
  end
end

eventhandlers = nagios_bags.get(node['nagios']['eventhandlers_databag'])
eventhandlers.each do |item|
  name = item['command_name'] || item['id']
  nagios_command name do
    options item
  end
end

contacts = nagios_bags.get(node['nagios']['contacts_databag'])
contacts.each do |item|
  name = item['contact_name'] || item['id']
  nagios_contact name do
    options item
  end
end

hostescalations = nagios_bags.get(node['nagios']['hostescalations_databag'])
hostescalations.each do |item|
  name = item['host_description'] || item['id']
  nagios_hostescalation name do
    options item
  end
end

hosttemplates = nagios_bags.get(node['nagios']['hosttemplates_databag'])
hosttemplates.each do |item|
  name = item['host_name'] || item['id']
  item['name'] = name if item['name'].nil?
  nagios_host name do
    options item
  end
end

servicedependencies = nagios_bags.get(node['nagios']['servicedependencies_databag'])
servicedependencies.each do |item|
  name = item['service_description'] || item['id']
  nagios_servicedependency name do
    options item
  end
end

serviceescalations = nagios_bags.get(node['nagios']['serviceescalations_databag'])
serviceescalations.each do |item|
  name = item['service_description'] || item['id']
  nagios_serviceescalation name do
    options item
  end
end

servicegroups = nagios_bags.get(node['nagios']['servicegroups_databag'])
servicegroups.each do |item|
  name = item['servicegroup_name'] || item['id']
  nagios_servicegroup name do
    options item
  end
end

templates = nagios_bags.get(node['nagios']['templates_databag'])
templates.each do |item|
  name = item['name'] || item['id']
  item['name'] = name
  nagios_service name do
    options item
  end
end

timeperiods = nagios_bags.get(node['nagios']['timeperiods_databag'])
timeperiods.each do |item|
  name = item['timeperiod_name'] || item['id']
  nagios_timeperiod name do
    options item
  end
end

unmanaged_hosts = nagios_bags.get(node['nagios']['unmanagedhosts_databag'])
unmanaged_hosts.each do |item|
  if node['nagios']['multi_environment_monitoring'].nil?
    next if item['environment'].nil? || item['environment'] != node.chef_environment
  else
    envs = node['nagios']['monitored_environments']
    next if item['environment'].nil? || !envs.include?(item['environment'])
  end
  name = item['host_name'] || item['id']
  nagios_host name do
    options item
  end
end
