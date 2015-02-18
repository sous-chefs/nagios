#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Provider:: resourcelist_items
#
# Copyright 2015, Sander Botman
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

action :update do
  run_context.resource_collection.each do |r|
    case r
    when Chef::Resource::NagiosCommand
      update_object(r, 'commands', Nagios::Command)
    when Chef::Resource::NagiosContact
      update_object(r, 'contacts', Nagios::Contact)
    when Chef::Resource::NagiosContactgroup
      update_object(r, 'contactgroups', Nagios::Contactgroup)
    when Chef::Resource::NagiosHost
      update_object(r, 'hosts', Nagios::Host)
    when Chef::Resource::NagiosHostdependency
      update_object(r, 'hostdependencies', Nagios::Hostdependency)
    when Chef::Resource::NagiosHostescalation
      update_object(r, 'hostescalations', Nagios::Hostescalation)
    when Chef::Resource::NagiosHostgroup
      update_object(r, 'hostgroups', Nagios::Hostgroup)
    when Chef::Resource::NagiosResource
      update_object(r, 'resources', Nagios::Resource)
    when Chef::Resource::NagiosService
      update_object(r, 'services', Nagios::Service)
    when Chef::Resource::NagiosServicedependency
      update_object(r, 'servicedependencies', Nagios::Servicedependency)
    when Chef::Resource::NagiosServiceescalation
      update_object(r, 'serviceescalations', Nagios::Serviceescalation)
    when Chef::Resource::NagiosServicegroup
      update_object(r, 'servicegroups', Nagios::Servicegroup)
    when Chef::Resource::NagiosTimeperiod
      update_object(r, 'timeperiods', Nagios::Timeperiod)
    end
  end
  new_resource.updated_by_last_action(false)
end

private

def update_object(obj, entry, type)
  if obj.action == :delete || obj.action == :remove
    Nagios.instance.delete(entry, obj.name)
  else
    o = type.create(obj.name)
    o.import(obj.options)
  end
end
