#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
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
    result = search(:node, group['search_query'])
  else
    result = search(:node, "#{group['search_query']} AND chef_environment:#{node.chef_environment}")
  end

  result.each do |n|
    n.automatic_attrs['roles'] = [group['hostgroup_name']]
    Nagios.instance.push(n)
  end
end

contactgroups = nagios_bags.get(node['nagios']['contactgroups_databag'])
contactgroups.each do |item|
  nagios_contactgroup item['id'] do
    options item
  end
end

contacts = nagios_bags.get(node['nagios']['contacts_databag'])
contacts.each do |item|
  nagios_contact item['id'] do
    options item
  end
end

eventhandlers = nagios_bags.get(node['nagios']['eventhandlers_databag'])
eventhandlers.each do |item|
  nagios_command item['id'] do
    options item
  end
end

hostescalations = nagios_bags.get(node['nagios']['hostescalations_databag'])
hostescalations.each do |item|
  nagios_hostescalation item['id'] do
    options item
  end
end

hosttemplates = nagios_bags.get(node['nagios']['hosttemplates_databag'])
hosttemplates.each do |item|
  item['name'] = item['id']
  nagios_host item['id'] do
    options item
  end
end

servicedependencies = nagios_bags.get(node['nagios']['servicedependencies_databag'])
servicedependencies.each do |item|
  nagios_servicedependency item['id'] do
    options item
  end
end

serviceescalations = nagios_bags.get(node['nagios']['serviceescalations_databag'])
serviceescalations.each do |item|
  nagios_serviceescalation item['id'] do
    options item
  end
end

servicegroups = nagios_bags.get(node['nagios']['servicegroups_databag'])
servicegroups.each do |item|
  nagios_servicegroup item['id'] do
    options item
  end
end

services = nagios_bags.get(node['nagios']['services_databag'])
services.each do |item|
  command_name = item['id'].downcase.start_with?('check_') ? item['id'].downcase : 'check_' + item['id'].downcase
  service_name = item['id'].downcase.start_with?('check_') ? item['id'].gsub('check_', '') : item['id'].downcase
  item['check_command'] = command_name

  nagios_command command_name do
    options item
  end

  nagios_service service_name do
    options item
  end
end
templates = nagios_bags.get(node['nagios']['templates_databag'])
templates.each do |item|
  item['name'] = item['id']
  nagios_service item['id'] do
    options item
  end
end

timeperiods = nagios_bags.get(node['nagios']['timeperiods_databag'])
timeperiods.each do |item|
  nagios_timeperiod item['id'] do
    options item
  end
end

unmanaged_hosts = nagios_bags.get(node['nagios']['unmanagedhosts_databag'])
unmanaged_hosts.each do |item|
  nagios_host item['id'] do
    options item
  end
end
