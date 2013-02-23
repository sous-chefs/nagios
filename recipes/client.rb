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

# Shamelessly stolen from cluster_service_discovery.  Big ups to Infochimps!
def build_query options = {} 
  opts = Hash.new
  opts[:chef_environment] = "#{node.chef_environment}" unless node['nagios']['multi_environment_monitoring']
  opts[:cluster_name]     = "#{node.cluster_name}" unless node['nagios']['cluster_nagios'].nil?
  opts[:hostname]         = "[* TO *]"
  opts[:role]             = node['nagios']['server_role']
  query = opts.collect { |k,v| "#{k}:#{v}" }. join(" AND ")
  Chef::Log.debug "Searching for #{query}"
  query
end

# determine hosts that NRPE will allow monitoring from
mon_host = ['127.0.0.1']

if node.run_list.roles.include?(node['nagios']['server_role'])
  mon_host << node['ipaddress']
else
  search(:node, build_query)
    mon_host << n['ipaddress']
  end
end

include_recipe "nagios::client_#{node['nagios']['client']['install_method']}"

directory "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d" do
  owner "root"
  group "root"
  mode 00755
end

template "#{node['nagios']['nrpe']['conf_dir']}/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "root"
  group "root"
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
