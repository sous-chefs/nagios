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

php_install 'php'

apache2_install 'nagios' do
  listen node['nagios']['enable_ssl'] ? %w(80 443) : %w(80)
  mpm node['nagios']['apache_mpm']
end

apache2_module 'cgi'
apache2_module 'rewrite'
if apache_mod_php_supported?
  apache2_mod_php 'nagios'
  apache_php_handler = 'application/x-httpd-php'
else
  apache2_module 'proxy'
  apache2_module 'proxy_fcgi'
  apache2_mod_proxy 'proxy'
  php_fpm_pool 'nagios' do
    user default_apache_user
    group default_apache_group
    listen_user default_apache_user
    listen_group default_apache_group
  end
  apache_php_handler = "proxy:unix:#{php_fpm_socket}|fcgi://localhost"
end

apache2_module 'ssl' if node['nagios']['enable_ssl']

apache2_site '000-default' do
  action :disable
  notifies :reload, 'apache2_service[nagios]'
end

template "#{apache_dir}/sites-available/#{node['nagios']['server']['vname']}.conf" do
  source 'apache2.conf.erb'
  mode '0644'
  variables(
    nagios_url: node['nagios']['url'],
    https: node['nagios']['enable_ssl'],
    ssl_cert_file: node['nagios']['ssl_cert_file'],
    ssl_cert_key: node['nagios']['ssl_cert_key'],
    apache_log_dir: default_log_dir,
    apache_php_handler: apache_php_handler
  )
  notifies :restart, 'apache2_service[nagios]' if File.symlink?("#{apache_dir}/sites-enabled/#{node['nagios']['server']['vname']}.conf")
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
  apache2_module 'auth_openid' do
    notifies :reload, 'apache2_service[nagios]'
  end
when 'cas'
  apache2_module 'auth_cas' do
    notifies :reload, 'apache2_service[nagios]'
  end
when 'ldap'
  package 'mod_ldap' if platform_family?('rhel')

  %w(ldap authnz_ldap).each do |m|
    apache2_module m do
      notifies :reload, 'apache2_service[nagios]'
    end
  end
when 'htauth'
  Chef::Log.info('Authentication method htauth configured in server.rb')
else
  Chef::Log.info('Default method htauth configured in server.rb')
end

apache2_service 'nagios' do
  action [:enable, :start]
  subscribes :restart, 'apache2_install[nagios]'
  subscribes :reload, 'apache2_module[cgi]'
  subscribes :reload, 'apache2_module[rewrite]'
  subscribes :reload, 'apache2_mod_php[nagios]' if apache_mod_php_supported?
  subscribes :reload, 'apache2_module[proxy]' unless apache_mod_php_supported?
  subscribes :reload, 'apache2_module[proxy_fcgi]' unless apache_mod_php_supported?
  subscribes :reload, 'apache2_mod_proxy[proxy]' unless apache_mod_php_supported?
  subscribes :reload, 'apache2_module[ssl]' if node['nagios']['enable_ssl']
end

include_recipe 'nagios::server'
