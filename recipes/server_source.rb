#
# Author:: Seth Chisamore <schisamo@chef.io>
# Author:: Tim Smith <tsmith@chef.io>
# Cookbook:: nagios
# Recipe:: server_source
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

# Package pre-reqs
include_recipe 'build-essential'
include_recipe 'php::default'
include_recipe 'php::module_gd'

# the source install of nagios from this recipe does not include embedded perl support
# so unless the user explicitly set the p1_file attribute, we want to clear it
# Note: the cookbook now defaults to Nagios 4.X which doesn't support embedded perl anyways
node.default['nagios']['conf']['p1_file'] = nil

pkgs = value_for_platform_family(
  'rhel' => %w(openssl-devel gd-devel tar),
  'debian' => %w(libssl-dev libgd2-xpm-dev bsd-mailx tar),
  'default' => %w(libssl-dev libgd2-xpm-dev bsd-mailx tar)
)

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

user node['nagios']['user'] do
  action :create
end

web_srv = node['nagios']['server']['web_server']

group node['nagios']['group'] do
  members [
    node['nagios']['user'],
    web_srv == 'nginx' ? node['nginx']['user'] : node['apache']['user'],
  ]
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/nagios_core.tar.gz" do
  source node['nagios']['server']['url']
  checksum node['nagios']['server']['checksum']
end

node['nagios']['server']['patches'].each do |patch|
  remote_file "#{Chef::Config[:file_cache_path]}/#{patch}" do
    source "#{node['nagios']['server']['patch_url']}/#{patch}"
  end
end

execute 'extract-nagios' do
  cwd Chef::Config[:file_cache_path]
  command 'tar zxvf nagios_core.tar.gz'
  not_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/#{node['nagios']['server']['src_dir']}") }
end

node['nagios']['server']['patches'].each do |patch|
  bash "patch-#{patch}" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOF
      cd #{node['nagios']['server']['src_dir']}
      patch -p1 --forward --silent --dry-run < '#{Chef::Config[:file_cache_path]}/#{patch}' >/dev/null
      if [ $? -eq 0 ]; then
        patch -p1 --forward < '#{Chef::Config[:file_cache_path]}/#{patch}'
      else
        exit 0
      fi
    EOF
    action :nothing
    subscribes :run, 'execute[extract-nagios]', :immediately
  end
end

bash 'compile-nagios' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    cd #{node['nagios']['server']['src_dir']}
    ./configure --prefix=/usr \
        --mandir=/usr/share/man \
        --bindir=/usr/sbin \
        --sbindir=#{node['nagios']['cgi-bin']} \
        --datadir=#{node['nagios']['docroot']} \
        --sysconfdir=#{node['nagios']['conf_dir']} \
        --infodir=/usr/share/info \
        --libexecdir=#{node['nagios']['plugin_dir']} \
        --localstatedir=#{node['nagios']['state_dir']} \
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
    make install-init
    make install-config
    make install-commandmode
    #{node['nagios']['source']['add_build_commands'].join("\n")}
  EOH
  action :nothing
  subscribes :run, 'execute[extract-nagios]', :immediately
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
