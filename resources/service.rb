#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Resource:: service
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
property :service_description, String
property :host_name, String
property :hostgroup_name, String
property :servicegroups, [Hash, Array]
property :display_name, String
property :is_volatile, [String, Integer]
property :check_command, String
property :initial_state, String
property :max_check_attempts, [String, Integer]
property :check_interval, [String, Integer]
property :retry_interval, [String, Integer]
property :active_checks_enabled, [String, Integer]
property :passive_checks_enabled, [String, Integer]
property :check_period, String
property :obsess_over_service, [String, Integer]
property :check_freshness, [String, Integer]
property :freshness_threshold, [String, Integer]
property :event_handler, String
property :event_handler_enabled, [String, Integer]
property :low_flap_threshold, [String, Integer]
property :high_flap_threshold, [String, Integer]
property :flap_detection_enabled, [String, Integer]
property :flap_detection_options, String
property :process_perf_data, [String, Integer]
property :retain_status_information, [String, Integer]
property :retain_nonstatus_information, [String, Integer]
property :notification_interval, [String, Integer]
property :first_notification_delay, [String, Integer]
property :notification_period, String
property :notification_options, String
property :notifications_enabled, [String, Integer]
property :parallelize_check, [String, Integer]
property :contacts, [Hash, Array]
property :contact_groups, [Hash, Array]
property :stalking_options, String
property :notes, String
property :notes_url, String
property :action_url, String
property :icon_image, String
property :icon_image_alt, String
property :register, [String, Integer]

action :create do
  o = Nagios::Service.create(new_resource.name)
  options = {
    use: new_resource.use,
    service_description: new_resource.service_description,
    host_name_list: new_resource.host_name,
    hostgroup_name_list: new_resource.hostgroup_name,
    servicegroups_list: new_resource.servicegroups,
    display_name: new_resource.display_name,
    is_volatile: new_resource.is_volatile,
    check_command: new_resource.check_command,
    initial_state: new_resource.initial_state,
    max_check_attempts: new_resource.max_check_attempts,
    check_interval: new_resource.check_interval,
    retry_interval: new_resource.retry_interval,
    active_checks_enabled: new_resource.active_checks_enabled,
    passive_checks_enabled: new_resource.passive_checks_enabled,
    check_period: new_resource.check_period,
    obsess_over_service: new_resource.obsess_over_service,
    check_freshness: new_resource.check_freshness,
    freshness_threshold: new_resource.freshness_threshold,
    event_handler: new_resource.event_handler,
    event_handler_enabled: new_resource.event_handler_enabled,
    low_flap_threshold: new_resource.low_flap_threshold,
    high_flap_threshold: new_resource.high_flap_threshold,
    flap_detection_enabled: new_resource.flap_detection_enabled,
    flap_detection_options: new_resource.flap_detection_options,
    process_perf_data: new_resource.process_perf_data,
    retain_status_information: new_resource.retain_status_information,
    retain_nonstatus_information: new_resource.retain_nonstatus_information,
    notification_interval: new_resource.notification_interval,
    first_notification_delay: new_resource.first_notification_delay,
    notification_period: new_resource.notification_period,
    notification_options: new_resource.notification_options,
    notifications_enabled: new_resource.notifications_enabled,
    parallelize_check: new_resource.parallelize_check,
    contacts_list: new_resource.contacts,
    contact_groups_list: new_resource.contact_groups,
    stalking_options: new_resource.stalking_options,
    notes: new_resource.notes,
    notes_url: new_resource.notes_url,
    action_url: new_resource.action_url,
    icon_image: new_resource.icon_image,
    icon_image_alt: new_resource.icon_image_alt,
    register: new_resource.register,
  }
  o.import(options)
end

action :delete do
  Nagios.instance.delete('service', new_resource.name)
end

action_class do
  require_relative '../libraries/service'
end
