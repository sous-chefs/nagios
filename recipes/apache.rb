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

node.default['nagios']['server']['web_server'] = 'apache'

include_recipe 'apache2'
include_recipe 'apache2::mod_cgi'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_php'
include_recipe 'apache2::mod_ssl' if node['nagios']['enable_ssl']

apache_site '000-default' do
  enable false
end

template "#{node['apache']['dir']}/sites-available/#{node['nagios']['server']['vname']}.conf" do
  source 'apache2.conf.erb'
  mode '0644'
  variables(
    nagios_url: node['nagios']['url'],
    https: node['nagios']['enable_ssl'],
    ssl_cert_file: node['nagios']['ssl_cert_file'],
    ssl_cert_key: node['nagios']['ssl_cert_key']
  )
  if File.symlink?("#{node['apache']['dir']}/sites-enabled/#{node['nagios']['server']['vname']}.conf")
    notifies :restart, 'service[apache2]'
  end
end

file "#{node['apache']['dir']}/conf.d/#{node['nagios']['server']['vname']}.conf" do
  action :delete
end

apache_site node['nagios']['server']['vname'] do
  notifies :restart, 'service[apache2]'
end

node.default['nagios']['web_user'] = node['apache']['user']
node.default['nagios']['web_group'] = node['apache']['group'] || node['apache']['user']

# configure the appropriate authentication method for the web server
case node['nagios']['server_auth_method']
when 'openid'
  include_recipe 'apache2::mod_auth_openid'
when 'cas'
  include_recipe 'apache2::mod_auth_cas'
when 'ldap'
  include_recipe 'apache2::mod_authnz_ldap'
when 'htauth'
  Chef::Log.info('Authentication method htauth configured in server.rb')
else
  Chef::Log.info('Default method htauth configured in server.rb')
end

include_recipe 'nagios::server'
