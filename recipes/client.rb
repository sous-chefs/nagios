#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: client
#
# Copyright 2009, 37signals
# Copyright 2009-2011, Opscode, Inc
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

# determine hosts that NRPE will allow monitoring from
mon_host = node['nagios']['allowed_hosts']

# put all nagios servers that you find in the NPRE config.
if node.run_list.roles.include?(node['nagios']['server_role'])
  mon_host << node['ipaddress']
elsif node['nagios']['multi_environment_monitoring']
  search(:node, "role:#{node['nagios']['server_role']}") do |n|
    mon_host << n['ipaddress']
  end
else
  search(:node, "role:#{node['nagios']['server_role']} AND chef_environment:#{node.chef_environment}") do |n|
    mon_host << n['ipaddress']
  end
end
# on the first run, search isn't available, so if you're the nagios server, go
# ahead and put your own IP address in the NRPE config (unless it's already there).
if node.run_list.roles.include?(node['nagios']['server_role'])
  unless mon_host.include?(node['ipaddress'])
    mon_host << node['ipaddress']
  end
end

mon_host.concat node['nagios']['allowed_hosts'] if node['nagios']['allowed_hosts']

include_recipe "nagios::client_#{node['nagios']['client']['install_method']}"

directory "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d" do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode 00755
end

template "#{node['nagios']['nrpe']['conf_dir']}/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner node['nagios']['user']
  group node['nagios']['group']
  mode 00644
  variables(
    :mon_host => mon_host,
    :nrpe_directory => "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d"
  )
  notifies :restart, "service[#{node['nagios']['nrpe']['service_name']}]"
end

service node['nagios']['nrpe']['service_name'] do
  action [:start, :enable]
  supports :restart => true, :reload => true, :status => true
end
