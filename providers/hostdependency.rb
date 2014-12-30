#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Provider:: hostdependency
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
  o = Nagios::Hostdependency.create(@new_resource.dependent_name)
  o.import(@new_resource.options)
end

action :delete do
  Nagios.instance.hostsdependencies.delete(@new_resource.dependent_name)
end

alias_method :action_add, :action_create
alias_method :action_remove, :action_delete
