#
# Author:: Seth Chisamore <schisamo@chef.io>
# Author:: Tim Smith <tsmith@chef.io>
# Cookbook:: nagios
# Recipe:: server_package
#
# Copyright 2011-2016, Chef Software, Inc.
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

case node['platform_family']
when 'rhel'
  include_recipe 'yum-epel' if node['nagios']['server']['install_yum-epel']
when 'debian'
  # Nagios package requires to enter the admin password
  # We generate it randomly as it's overwritten later in the config templates
  random_initial_password = rand(36**16).to_s(36)

  %w(adminpassword adminpassword-repeat).each do |setting|
    execute "debconf-set-selections::#{node['nagios']['server']['vname']}-cgi::#{node['nagios']['server']['vname']}/#{setting}" do
      command "echo #{node['nagios']['server']['vname']}-cgi #{node['nagios']['server']['vname']}/#{setting} password #{random_initial_password} | debconf-set-selections"
      not_if "dpkg -l #{node['nagios']['server']['vname']}"
    end
  end
end

node['nagios']['server']['packages'].each do |pkg|
  package pkg
end

directory node['nagios']['config_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

directory node['nagios']['conf']['check_result_path'] do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode '0755'
  recursive true
end

%w( cache_dir log_dir run_dir ).each do |dir|
  directory node['nagios'][dir] do
    recursive true
    owner node['nagios']['user']
    group node['nagios']['group']
    mode '0755'
  end
end

directory ::File.join(node['nagios']['log_dir'], 'archives') do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode '0755'
end

directory "/usr/lib/#{node['nagios']['server']['vname']}" do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode '0755'
end
