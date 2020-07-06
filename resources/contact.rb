#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: : nagios
# Resource:: : contact
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
property :nagios_alias, String
property :use, String
property :contact_name, String, name_property: true
property :contactgroups, Hash
property :host_notifications_enabled, String
property :service_notifications_enabled, String
property :host_notification_period, String
property :service_notification_period, String
property :host_notification_options, String
property :service_notification_options, String
property :host_notification_commands, String
property :service_notification_commands, String
property :email, String
property :pager, String
property :addressx, String
property :can_submit_commands, String
property :retain_status_information, String
property :retain_nonstatus_information, String
property :register, String

action :create do
  o = Nagios::Contact.create(new_resource.name)
  options = {
    alias: new_resource.nagios_alias,
    use: new_resource.use,
    contactgroups_list: new_resource.contactgroups,
    host_notifications_enabled: new_resource.host_notifications_enabled,
    service_notifications_enabled: new_resource.service_notifications_enabled,
    host_notification_period: new_resource.host_notification_period,
    service_notification_period: new_resource.service_notification_period,
    host_notification_options: new_resource.host_notification_options,
    service_notification_options: new_resource.service_notification_options,
    host_notification_commands: new_resource.host_notification_commands,
    service_notification_commands: new_resource.service_notification_commands,
    email: new_resource.email,
    pager: new_resource.pager,
    addressx: new_resource.addressx,
    can_submit_commands: new_resource.can_submit_commands,
    retain_status_information: new_resource.retain_status_information,
    retain_nonstatus_information: new_resource.retain_nonstatus_information,
    register: new_resource.register,
  }
  o.import(options)
end

action :delete do
  Nagios.instance.delete('contact', new_resource.name)
end

action_class do
  require_relative '../libraries/contact'
end
