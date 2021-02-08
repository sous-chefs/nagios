#
# Author:: Tim Smith <tsmith@chef.io>
# Cookbook:: nagios
# Recipe:: apache
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

service 'apache2' do
  service_name apache_platform_service_name
  supports restart: true, status: true, reload: true
  action :nothing
end

node.default['nagios']['server']['web_server'] = 'apache'

include_recipe 'php'

apache2_install 'default-install' do
  listen node['nagios']['enable_ssl'] ? %w(80 443) : %w(80)
  mpm node['nagios']['apache_mpm']
end
apache2_module 'cgi'
apache2_module 'rewrite'
apache2_mod_php
apache2_module 'ssl' if node['nagios']['enable_ssl']

apache2_site '000-default' do
  action :disable
end

template "#{apache_dir}/sites-available/#{node['nagios']['server']['vname']}.conf" do
  source 'apache2.conf.erb'
  mode '0644'
  variables(
    nagios_url: node['nagios']['url'],
    https: node['nagios']['enable_ssl'],
    ssl_cert_file: node['nagios']['ssl_cert_file'],
    ssl_cert_key: node['nagios']['ssl_cert_key'],
    apache_log_dir: default_log_dir
  )
  if File.symlink?("#{apache_dir}/sites-enabled/#{node['nagios']['server']['vname']}.conf")
    notifies :restart, 'service[apache2]'
  end
end

file "#{apache_dir}/conf.d/#{node['nagios']['server']['vname']}.conf" do
  action :delete
end

apache2_site node['nagios']['server']['vname']

node.default['nagios']['web_user'] = default_apache_user
node.default['nagios']['web_group'] = default_apache_group

# configure the appropriate authentication method for the web server
case node['nagios']['server_auth_method']
when 'openid'
  apache2_module 'auth_openid'
when 'cas'
  apache2_module 'auth_cas'
when 'ldap'
  apache2_module 'authnz_ldap'
when 'htauth'
  Chef::Log.info('Authentication method htauth configured in server.rb')
else
  Chef::Log.info('Default method htauth configured in server.rb')
end

include_recipe 'nagios::server'
