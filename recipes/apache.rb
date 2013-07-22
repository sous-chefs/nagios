# Cookbook Name:: nagios
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

include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_php5"

if node['nagios']['enable_ssl']
  include_recipe "apache2::mod_ssl"
end

apache_site "000-default" do
  enable false
end

public_domain = node['public_domain'] || node['domain']

template "#{node['apache']['dir']}/sites-available/nagios3.conf" do
  source "apache2.conf.erb"
  mode 00644
  variables( 
    :public_domain => public_domain,
    :nagios_url    => node['nagios']['url'],
    :https         => node['nagios']['enable_ssl'],
    :ssl_cert_file => node['nagios']['ssl_cert_file'],
    :ssl_cert_key  => node['nagios']['ssl_cert_key']
  )
  if ::File.symlink?("#{node['apache']['dir']}/sites-enabled/nagios3.conf")
    notifies :reload, "service[apache2]"
  end
end

file "#{node['apache']['dir']}/conf.d/nagios3.conf" do
  action :delete
end

apache_site "nagios3.conf"
