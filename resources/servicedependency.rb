#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Resource:: servicedependency
#
# Copyright:: 2015, Sander Botman
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

property :dependency_period, String
property :dependent_host_name, Hash
property :dependent_hostgroup_name, Hash
property :dependent_servicegroup_name, Hash
property :service_description, String, name_property: true
property :servicegroup_name, Hash
property :dependent_service_description, String
property :host_name, Hash
property :hostgroup_name, Hash
property :inherits_parent, String
property :execution_failure_criteria, String
property :notification_failure_criteria, String

action :create do
  o = Nagios::Servicedependency.create(new_resource.name)
  options = {
    dependency_period: new_resource.dependency_period,
    dependent_host_name_list: new_resource.dependent_host_name,
    dependent_hostgroup_name_list: new_resource.dependent_hostgroup_name,
    dependent_servicegroup_name_list: new_resource.dependent_servicegroup_name,
    service_description: new_resource.service_description,
    servicegroup_name_list: new_resource.servicegroup_name,
    dependent_service_description: new_resource.dependent_service_description,
    host_name_list: new_resource.host_name,
    hostgroup_name_list: new_resource.hostgroup_name,
    inherits_parent: new_resource.inherits_parent,
    execution_failure_criteria: new_resource.execution_failure_criteria,
    notification_failure_criteria: new_resource.notification_failure_criteria,
  }
  o.import(options)
end

action :delete do
  Nagios.instance.delete('servicedependency', new_resource.name)
end

action_class do
  require_relative '../libraries/servicedependency'
end
