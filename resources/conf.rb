# frozen_string_literal: true

provides :nagios_conf
#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@chef.io>
# Author:: Nathan Haneysmith <nathan@chef.io>
# Author:: Seth Chisamore <schisamo@chef.io>
# Cookbook:: nagios
# Resource:: nagios_conf
#
# Copyright:: 2009, 37signals
# Copyright:: 2009-2016, Chef Software, Inc.
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
property :variables, Hash, default: {}
property :config_subdir, [true, false], default: true
property :source, [String, nil]
property :cookbook, String, default: 'nagios'
property :conf_dir, String, required: true
property :config_dir, String, required: true
property :owner, String, default: 'nagios'
property :group, String, default: 'nagios'
property :service_name, String, default: 'nagios'
unified_mode true

action :create do
  conf_dir = new_resource.config_subdir ? new_resource.config_dir : new_resource.conf_dir
  template_source = new_resource.source || "#{new_resource.name}.cfg.erb"

  with_run_context(:root) do
    template "#{conf_dir}/#{new_resource.name}.cfg" do
      cookbook new_resource.cookbook if new_resource.cookbook
      owner new_resource.owner
      group new_resource.group
      source template_source
      mode '0644'
      variables new_resource.variables
      notifies :restart, "service[#{new_resource.service_name}]"
      backup 0
      action :nothing
      delayed_action :create
    end
  end
end

action :delete do
  conf_dir = new_resource.config_subdir ? new_resource.config_dir : new_resource.conf_dir

  file "#{conf_dir}/#{new_resource.name}.cfg" do
    action :delete
  end
end

action_class do
  require_relative '../libraries/nagios'
end
