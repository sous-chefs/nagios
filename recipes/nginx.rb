# Cookbook Name:: nagios
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

if node["nagios"]["server"]["stop_apache"]
  service 'apache2' do
    action :stop
  end
end

via_pkg = value_for_platform_family(
  %w(rhel fedora) => {
    %w(5.0 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8) => false,
    "default" => nil
  },
  "default" => true
)

if(via_pkg.nil?)
  node.set['nagios']['server']['nginx_dispatch'] = :both
elsif(via_pkg == false)
  node.set["nginx"]["install_method"] = 'source'
  node.set['nagios']['server']['nginx_dispatch'] = :both
end
include_recipe "nginx"

%w(default 000-default).each do |disable_site|
  nginx_site disable_site do
    enable false
    notifies :reload, "service[nginx]"
  end
end

if node['public_domain']
  public_domain = node['public_domain']
else
  public_domain = node['domain']
end

case dispatch_type = node['nagios']['server']['nginx_dispatch'].to_sym
when :cgi
  node.set["nginx_simplecgi"]["cgi"] = true
  include_recipe 'nginx_simplecgi::setup'
when :php
  node.set["nginx_simplecgi"]["php"] = true
  include_recipe 'nginx_simplecgi::setup'
when :both
  node.set["nginx_simplecgi"]["php"] = true
  node.set["nginx_simplecgi"]["cgi"] = true
  include_recipe 'nginx_simplecgi::setup'
else
  Chef::Log.warn "NAGIOS: NGINX setup does not have a dispatcher provided"
end

template File.join(node['nginx']['dir'], 'sites-available', 'nagios3.conf') do
  source 'nginx.conf.erb'
  mode 00644
  variables(
    :public_domain => public_domain,
    :listen_port   => node['nagios']['http_port'],
    :https         => node['nagios']['enable_ssl'],
    :ssl_cert_file => node['nagios']['ssl_cert_file'],
    :ssl_cert_key  => node['nagios']['ssl_cert_key'],
    :docroot       => node['nagios']['docroot'],
    :log_dir       => node['nagios']['log_dir'],
    :fqdn          => node['fqdn'],
    :nagios_url    => node['nagios']['url'],
    :chef_env =>  node.chef_environment == '_default' ? 'default' : node.chef_environment,
    :htpasswd_file => File.join(
      node['nagios']['conf_dir'],
      'htpasswd.users'
    ),
    :cgi => [:cgi, :both].include?(dispatch_type.to_sym),
    :php => [:php, :both].include?(dispatch_type.to_sym)
  )
  if(::File.symlink?(File.join(node['nginx']['dir'], 'sites-enabled', 'nagios3.conf')))
    notifies :reload, 'service[nginx]', :immediately
  end
end

nginx_site "nagios3.conf" do
  notifies :reload, "service[nginx]"
end

