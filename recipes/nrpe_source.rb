#
# Author:: Tim Smith <tsmith84@gmail.com>
# Cookbook Name:: nagios
# Recipe:: client_source
#
# Copyright 2013, Opscode, Inc
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

nrpe_version = node['nagios']['nrpe']['version']

remote_file "#{Chef::Config[:file_cache_path]}/nrpe-#{nrpe_version}.tar.gz" do
  source "#{node['nagios']['nrpe']['url']}/nrpe-#{nrpe_version}.tar.gz"
  checksum node['nagios']['nrpe']['checksum']
  action :create_if_missing
end

# handle a full install vs a plugin install.  plugin installs are called via the
# server_source.rb recipe.  full installs are called via client_source.rb

if node['nagios']['client']['install_method'] == "source"
  install_type = "install"

  template "/etc/init.d/#{node['nagios']['nrpe']['service_name']}" do
    source "nagios-nrpe-server.erb"
    owner node['nagios']['user']
    group node['nagios']['group']
    mode  00755
  end

  directory node['nagios']['nrpe']['conf_dir'] do
    owner node['nagios']['user']
    group node['nagios']['group']
    mode  00755
  end
else
  install_type = "install-plugin"
end

bash "compile-nagios-nrpe" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf nrpe-#{nrpe_version}.tar.gz
    cd nrpe-#{nrpe_version}
    ./configure --prefix=/usr \
                --sysconfdir=/etc \
                --localstatedir=/var \
                --libexecdir=#{node['nagios']['plugin_dir']} \
                --libdir=#{node['nagios']['nrpe']['home']} \
                --enable-command-args \
                --with-nagios-user=#{node['nagios']['user']} \
                --with-nagios-group=#{node['nagios']['group']} \
                --with-ssl=/usr/bin/openssl \
                --with-ssl-lib=#{node['nagios']['nrpe']['ssl_lib_dir']}
    make -s
    make #{install_type}
  EOH
  creates "#{node['nagios']['plugin_dir']}/check_nrpe"
end
