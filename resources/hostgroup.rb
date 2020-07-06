#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Resource:: hostgroup
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
property :hostgroup_name, String, name_property: true
property :members, Hash
property :hostgroup_members, Hash
property :nagios_alias, String
property :notes, String
property :notes_url, String
property :action_url, String
property :register, String

action :create do
  o = Nagios::Hostgroup.create(new_resource.name)
  options = {
    use: new_resource.use,
    hostgroup_name: new_resource.name,
    members_list: new_resource.members,
    hostgroup_members_list: new_resource.hostgroup_members,
    alias: new_resource.nagios_alias,
    notes: new_resource.notes,
    notes_url: new_resource.notes_url,
    action_url: new_resource.action_url,
    register: new_resource.register,
  }
  o.import(options)
end

action :delete do
  Nagios.instance.delete('hostgroup', new_resource.name)
end

action_class do
  require_relative '../libraries/hostgroup'
end
