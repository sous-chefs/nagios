#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Provider:: nagios_host
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
#

action :create do
  o = Nagios::Host.create(@new_resource.host_name)
  o.import(@new_resource.options)
  new_resource.updated_by_last_action(false)
end

action :delete do
  Nagios.instance.hosts.delete(@new_resource.host_name)
  new_resource.updated_by_last_action(false)
end

alias_method :action_add, :action_create
alias_method :action_remove, :action_delete
