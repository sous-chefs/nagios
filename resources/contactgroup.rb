#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Resource:: contactgroup
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
property :contactgroup_name, String
property :members, [Hash, Array]
property :contactgroup_members, [Hash, Array]
property :register, [String, Integer]

action :create do
  o = Nagios::Contactgroup.create(new_resource.name)
  options = {
    name: new_resource.name,
    use: new_resource.use,
    contactgroup_name: new_resource.contactgroup_name,
    members_list: new_resource.members,
    contactgroup_members_list: new_resource.contactgroup_members,
    alias: new_resource.nagios_alias,
    register: new_resource.register,
  }
  o.import(options)
end

action :delete do
  Nagios.instance.delete('contactgroup', new_resource.name)
end

action_class do
  require_relative '../libraries/contactgroup'
end
