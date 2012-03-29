include_recipe "nginx"

nginx_site "000-default" do
  enable false
  notifies :reload, "service[nginx]"
end

if node['public_domain']
  public_domain = node['public_domain']
else
  public_domain = node['domain']
end

template File.join(node['nginx']['dir'], *%w(sites-available nagios3.conf)) do
  source 'nginx.conf.erb'
  mode 0644
  pem = File.join(
    node['nagios']['conf_dir'],
    'certificates',
    'nagios-server.pem'
  )
  variables(
    :public_domain => public_domain,
    :listen_port => node['nagios']['http_port'],
    :https => node['nagios']['https'],
    :cert_file => pem,
    :cert_key => pem,
    :docroot => node['nagios']['docroot'],
    :log_dir => node['nagios']['log_dir'],
    :fqdn => node['fqdn'],
    :chef_env =>  node.chef_environment == '_default' ? 'default' : node.chef_environment,
    :htpasswd_file => File.join(
      node['nagios']['conf_dir'],
      'htpasswd.users'
    )
  )
  if(File.symlink?(File.join(node['nginx']['dir'], 'sites-enabled', 'nagios3.conf')))
    notifies :reload, 'service[nginx]', :immediately
  end
end

nginx_site "nagios3.conf" do
  notifies :reload, "service[nginx]"
end

