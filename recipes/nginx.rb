#
# Author:: Tim Smith <tsmith@chef.io>
# Cookbook:: nagios
# Recipe:: nginx
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

::Chef::Recipe.include Nginx::Cookbook::Helpers
::Chef::Recipe.include Apache2::Cookbook::Helpers
::Chef::Resource.include Nginx::Cookbook::Helpers

service 'nginx' do
  supports status: true, restart: true, reload: true
  action :nothing
end

node.default['nagios']['server']['web_server'] = 'nginx'

nginx_install 'default' do
  source 'distro'
  default_site_enabled false
end

include_recipe 'php'

php_fpm_pool 'nagios' do
  user node['nginx']['user']
  group node['nginx']['group']
end

package nagios_array(node['nagios']['server']['nginx_dispatch']['packages'])

if platform_family?('rhel')
  template '/etc/sysconfig/spawn-fcgi' do
    source 'spawn-fcgi.erb'
    notifies :start, 'service[spawn-fcgi]', :delayed
    variables(
      nginx_user: nginx_user
    )
  end
end

nagios_array(node['nagios']['server']['nginx_dispatch']['services']).each do |svc|
  service svc do
    action [:enable, :start]
  end
end

dispatch_type = node['nagios']['server']['nginx_dispatch']['type']

file "#{nginx_dir}/conf.d/default.conf" do
  action :delete
  notifies :reload, 'service[nginx]', :immediately
end

template "#{nginx_dir}/sites-available/nagios3.conf" do
  source 'nginx.conf.erb'
  mode '0644'
  variables(
    allowed_ips: node['nagios']['allowed_ips'],
    cgi: %w(cgi both).include?(dispatch_type),
    cgi_bin_dir: platform_family?('rhel') ? '/usr/lib64' : '/usr/lib',
    chef_env: node.chef_environment == '_default' ? 'default' : node.chef_environment,
    docroot: node['nagios']['docroot'],
    fqdn: node['fqdn'],
    htpasswd_file: File.join(node['nagios']['conf_dir'], 'htpasswd.users'),
    https: node['nagios']['enable_ssl'],
    listen_port: node['nagios']['http_port'],
    log_dir: node['nagios']['log_dir'],
    nagios_url: node['nagios']['url'],
    nginx_dispatch_cgi_url: node['nagios']['server']['nginx_dispatch']['cgi_url'],
    nginx_dispatch_php_url: node['nagios']['server']['nginx_dispatch']['php_url'],
    php: %w(php both).include?(dispatch_type),
    public_domain: node['public_domain'] || node['domain'],
    server_name: node['nagios']['server']['name'],
    server_vname: node['nagios']['server']['vname'],
    ssl_cert_file: node['nagios']['ssl_cert_file'],
    ssl_cert_key: node['nagios']['ssl_cert_key']
  )
  if File.symlink?("#{nginx_dir}/sites-enabled/nagios3.conf")
    notifies :reload, 'service[nginx]', :immediately
  end
end

nginx_site 'nagios3.conf' do
  notifies :reload, 'service[nginx]'
end

node.default['nagios']['web_user'] = nginx_user
node.default['nagios']['web_group'] = nginx_user

# configure the appropriate authentication method for the web server
case node['nagios']['server_auth_method']
when 'openid'
  Chef::Log.fatal('OpenID authentication for Nagios is not supported on NGINX')
  Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your Nagios role")
  raise 'OpenID authentication not supported on NGINX'
when 'cas'
  Chef::Log.fatal('CAS authentication for Nagios is not supported on NGINX')
  Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your Nagios role")
  raise 'CAS authentivation not supported on NGINX'
when 'ldap'
  Chef::Log.fatal('LDAP authentication for Nagios is not supported on NGINX')
  Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your Nagios role")
  raise 'LDAP authentication not supported on NGINX'
else
  # setup htpasswd auth
  Chef::Log.info('Default method htauth configured in server.rb')
end

include_recipe 'nagios::server'

service apache_platform_service_name do
  action [:disable, :stop]
  notifies :start, 'service[nginx]', :delayed
  notifies :restart, 'service[nagios]', :delayed
end

execute 'fix_docroot_perms' do
  command "chgrp -R #{node['nagios']['web_group']} #{node['nagios']['docroot']}"
  action :nothing
end

if platform_family?('rhel')
  directory node['nagios']['docroot'] do
    group nginx_user
    notifies :run, 'execute[fix_docroot_perms]', :before
    action :create
  end
end
