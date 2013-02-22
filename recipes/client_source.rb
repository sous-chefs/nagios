#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: client_source
#
# Copyright 2011, Opscode, Inc
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

include_recipe "build-essential"

pkgs = value_for_platform_family(
    ["rhel","fedora"] => ["openssl-devel","make","tar"] ,
    "debian" => ["libssl-dev","make","tar"],
    "default" => ["libssl-dev","make","tar"]
  )

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

user node['nagios']['user'] do
  system true
end

group node['nagios']['group'] do
  members [ node['nagios']['user'] ]
end

plugins_version = node['nagios']['plugins']['version']

remote_file "#{Chef::Config[:file_cache_path]}/nagios-plugins-#{plugins_version}.tar.gz" do
  source "#{node['nagios']['plugins']['url']}/nagios-plugins-#{plugins_version}.tar.gz"
  checksum node['nagios']['plugins']['checksum']
  action :create_if_missing
end

bash "compile-nagios-plugins" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf nagios-plugins-#{plugins_version}.tar.gz
    cd nagios-plugins-#{plugins_version}
    ./configure --with-nagios-user=#{node['nagios']['user']} \
                --with-nagios-group=#{node['nagios']['group']} \
                --prefix=/usr \
                --libexecdir=#{node['nagios']['plugin_dir']}
    make -s
    make install
  EOH
  creates "#{node['nagios']['plugin_dir']}/check_users"
end

# compile the NRPE service and NRPE plugin
include_recipe "nagios::nrpe_source"

