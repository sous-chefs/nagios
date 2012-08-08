include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_rewrite"

case node['nagios']['server_auth_method']
when "openid"
  include_recipe "apache2::mod_auth_openid"
else
  sysadmins = node['nagios']['sysadmins'] || search(:users, 'groups:sysadmin')

  dir = node['nagios']['conf_dir']
  owner = node['nagios']['user']
  group = node['apache']['user']

  directory dir do
    owner owner
    group group
    mode 00750
    action :create
  end

  template "#{dir}/htpasswd.users" do
    source "htpasswd.users.erb"
    owner owner
    group group
    mode 00640
    variables(
      :sysadmins => sysadmins
    )
  end
end

apache_site "000-default" do
  enable false
end

if node['public_domain']
  public_domain = node['public_domain']
else
  public_domain = node['domain']
end

ssl_certificate_file = node['nagios']['ssl_certificate_file'] ||
  "#{node['nagios']['conf_dir']}/certificates/nagios-server.pem"
ssl_certificate_key_file = node['nagios']['ssl_certificate_key_file'] ||
  "#{node['nagios']['conf_dir']}/certificates/nagios-server.pem"

template "#{node['apache']['dir']}/sites-available/nagios3.conf" do
  source "apache2.conf.erb"
  mode 00644
  variables(
      :ssl_certificate_file => ssl_certificate_file,
      :ssl_certificate_key_file => ssl_certificate_key_file,
      :ssl_certificate_chain_file => node['nagios']['ssl_certificate_chain_file'],
      :public_domain => public_domain
  )
  if ::File.symlink?("#{node['apache']['dir']}/sites-enabled/nagios3.conf")
    notifies :reload, "service[apache2]"
  end
end

file "#{node['apache']['dir']}/conf.d/nagios3.conf" do
  action :delete
end

apache_site "nagios3.conf"
