#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Resource:: serviceescalation
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
property :use, String
property :service_description, String, name_property: true
property :contacts, Hash
property :contact_groups, Hash
property :escalation_period, String
property :host_name, Hash
property :hostgroup_name, Hash
property :servicegroup_name, Hash
property :escalation_options, String
property :first_notification, String
property :last_notification, String
property :notification_interval, String
property :register, String

action :create do
  o = Nagios::Serviceescalation.create(new_resource.name)
  options = {
    use: new_resource.use,
    service_description: new_resource.name,
    contacts_list: new_resource.contacts,
    contact_groups_list: new_resource.contact_groups,
    escalation_period: new_resource.escalation_period,
    host_name_list: new_resource.host_name,
    hostgroup_name_list: new_resource.hostgroup_name,
    servicegroup_name_list: new_resource.servicegroup_name,
    escalation_options: new_resource.escalation_options,
    first_notification: new_resource.first_notification,
    last_notification: new_resource.last_notification,
    notification_interval: new_resource.notification_interval,
    register: new_resource.register,
  }
  o.import(options)
  Nagios.instance.push(o)
end

action :delete do
  Nagios.instance.delete('serviceescalation', new_resource.name)
end

action_class do
  require_relative '../libraries/serviceescalation'
end
