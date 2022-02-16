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
property :source, String
property :cookbook, String, default: 'nagios'
unified_mode true

action :create do
  conf_dir = new_resource.config_subdir ? node['nagios']['config_dir'] : node['nagios']['conf_dir']
  source ||= "#{new_resource.name}.cfg.erb"

  with_run_context(:root) do
    template "#{conf_dir}/#{new_resource.name}.cfg" do
      cookbook new_resource.cookbook if new_resource.cookbook
      owner 'nagios'
      group 'nagios'
      source source
      mode '0644'
      variables new_resource.variables
      notifies :restart, 'service[nagios]'
      backup 0
      action :nothing
      delayed_action :create
    end
  end
end

action_class do
  require_relative '../libraries/nagios'
end
