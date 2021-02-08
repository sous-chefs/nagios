#
# Author:: Seth Chisamore <schisamo@chef.io>
# Author:: Tim Smith <tsmith@chef.io>
# Cookbook:: nagios
# Recipe:: server_source
#
# Copyright:: 2011-2016, Chef Software, Inc.
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

# Package pre-reqs
build_essential 'install compilation tools'
include_recipe 'php::default'

package node['nagios']['php_gd_package']

# the source install of nagios from this recipe does not include embedded perl support
# so unless the user explicitly set the p1_file attribute, we want to clear it
# Note: the cookbook now defaults to Nagios 4.X which doesn't support embedded perl anyways
node.default['nagios']['conf']['p1_file'] = nil

package node['nagios']['server']['dependencies']

user node['nagios']['user'] do
  action :create
end

web_srv = node['nagios']['server']['web_server']

group node['nagios']['group'] do
  members [
    node['nagios']['user'],
    web_srv == 'nginx' ? nginx_user : default_apache_user,
  ]
  action :create
end

nagios_version = node['nagios']['server']['version']

node['nagios']['server']['patches'].each do |patch|
  remote_file "#{Chef::Config[:file_cache_path]}/#{patch}" do
    source "#{node['nagios']['server']['patch_url']}/#{patch}"
  end
end

remote_file 'nagios source file' do
  path ::File.join(Chef::Config[:file_cache_path], "nagios-#{nagios_version}.tar.gz")
  source nagios_source_url
  checksum node['nagios']['server']['checksum']
  notifies :run, 'execute[compile-nagios]', :immediately
end

execute 'compile-nagios' do
  cwd Chef::Config[:file_cache_path]
  command <<-EOH
    tar xzf nagios-#{nagios_version}.tar.gz
    cd nagios-#{nagios_version}
    ./configure --prefix=/usr \
        --mandir=/usr/share/man \
        --bindir=/usr/sbin \
        --sbindir=#{node['nagios']['cgi-bin']} \
        --datadir=#{node['nagios']['docroot']} \
        --sysconfdir=#{node['nagios']['conf_dir']} \
        --infodir=/usr/share/info \
        --libexecdir=#{node['nagios']['plugin_dir']} \
        --localstatedir=#{node['nagios']['state_dir']} \
        --with-cgibindir=#{node['nagios']['cgi-bin']} \
        --enable-event-broker \
        --with-nagios-user=#{node['nagios']['user']} \
        --with-nagios-group=#{node['nagios']['group']} \
        --with-command-user=#{node['nagios']['user']} \
        --with-command-group=#{node['nagios']['group']} \
        --with-init-dir=/etc/init.d \
        --with-lockfile=#{node['nagios']['run_dir']}/#{node['nagios']['server']['vname']}.pid \
        --with-mail=/usr/bin/mail \
        --with-perlcache \
        --with-htmurl=/ \
        --with-cgiurl=#{node['nagios']['cgi-path']}
    make all
    make install
    make install-cgis
    make install-init
    make install-config
    make install-commandmode
    #{node['nagios']['source']['add_build_commands'].join("\n")}
  EOH
  action :nothing
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

%w(cache_dir log_dir run_dir).each do |dir|
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
