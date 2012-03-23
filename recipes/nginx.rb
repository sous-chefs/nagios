include_recipe "nginx"

nginx_site "default" do
  enable false
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
    :htpasswd_file => File.join(
      node['nagios']['conf_dir'],
      'htpasswd.users'
    )
  )
  if(File.symlink?(File.join(node['nginx']['dir'], 'sites-enabled', 'nagios3.conf')))
    notifies :reload, 'service[nginx]'
  end
end

nginx_site "nagios3.conf"

