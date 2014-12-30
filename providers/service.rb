#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Provider:: service
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

def whyrun_supported?
  true
end

action :create do
  name = @new_resource.service_name.downcase
  command_name = name.start_with?('check_') ? name : 'check_' + name
  service_name = name.start_with?('check_') ? name.gsub('check_','') : name
 
  command = Nagios::Command.create(command_name)
  command.import(@new_resource.options)

  service = Nagios::Service.create(service_name)
  service.import(@new_resource.options)
  service.push(command)
end

action :delete do
  Nagios.instance.services.delete(@new_resource.service_name)
end

alias_method :action_add, :action_create
alias_method :action_remove, :action_delete
