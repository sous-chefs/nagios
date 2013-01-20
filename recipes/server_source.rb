#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: server_source
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

# Package pre-reqs

include_recipe "build-essential"
include_recipe "nagios::client"
include_recipe "php"
include_recipe "php::module_gd"

node.default['nagios']['server']['service_name'] = node['nagios']['server']['engine']

web_srv = node['nagios']['server']['web_server'].to_sym

case web_srv
when :apache
  include_recipe "nagios::apache"
else
  include_recipe "nagios::nginx"
end

pkgs = value_for_platform_family(
  [ "rhel","fedora" ] => %w{ openssl-devel gd-devel },
  "debian" => %w{ libssl-dev libgd2-xpm-dev bsd-mailx },
  "default" => %w{ libssl-dev libgd2-xpm-dev bsd-mailx }
)

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end


user node['nagios']['user']
group node['nagios']['group'] do
  members [
    node['nagios']['user'],
    web_srv == :nginx ? node['nginx']['user'] : node['apache']['user']
  ]
  action [:create, :modify]
end

engine = node['nagios']['server']['engine']
basename = node['nagios']['basename']
version = node['nagios']['server'][engine]['version']
srcdir = engine=='nagios' ? 'nagios' : "#{engine}-#{version}"
docroot_opt = engine=='nagios' ? 'datadir' : 'datarootdir'

remote_file "#{Chef::Config[:file_cache_path]}/#{engine}-#{version}.tar.gz" do
  source "http://prdownloads.sourceforge.net/sourceforge/#{engine}/#{engine}-#{version}.tar.gz"
  checksum node['nagios']['server'][engine]['checksum']
  action :create_if_missing
end

bash "compile-nagios" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    set -e -x
    rm -rf #{srcdir}
    tar zxf #{engine}-#{version}.tar.gz
    cd #{ srcdir }
    ./configure --prefix=/usr \
        --mandir=/usr/share/man \
        --bindir=/usr/sbin \
        --sbindir=/usr/lib/cgi-bin/#{basename} \
        --#{docroot_opt}=#{node['nagios']['docroot']} \
        --sysconfdir=#{node['nagios']['conf_dir']} \
        --infodir=/usr/share/info \
        --libexecdir=#{node['nagios']['plugin_dir']} \
        --localstatedir=#{node['nagios']['state_dir']} \
        --enable-event-broker \
        --with-#{engine}-user=#{node['nagios']['user']} \
        --with-#{engine}-group=#{node['nagios']['group']} \
        --with-command-user=#{node['nagios']['user']} \
        --with-command-group=#{node['nagios']['group']} \
        --with-init-dir=/etc/init.d \
        --with-lockfile=#{node['nagios']['run_dir']}/#{basename}.pid \
        --with-mail=/usr/bin/mail \
        --with-perlcache \
        --with-htmurl=/#{basename} \
        --with-cgiurl=/cgi-bin/#{basename}
    make all
    make install
    make install-init
    make install-config
    make install-commandmode
  EOH
  creates "/usr/sbin/#{engine}"
end

directory "#{node['nagios']['conf_dir']}/conf.d" do
  owner "root"
  group "root"
  mode 00755
end

%w{ cache_dir log_dir run_dir }.each do |dir|

  directory node['nagios'][dir] do
    owner node['nagios']['user']
    group node['nagios']['group']
    mode 00755
  end

end

directory "/usr/lib/#{basename}" do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode 00755
end

link "#{node['nagios']['conf_dir']}/stylesheets" do
  to "#{node['nagios']['docroot']}/stylesheets"
end

if web_srv == :apache
  apache_module "cgi" do
    enable :true
  end
end
