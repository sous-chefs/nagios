# frozen_string_literal: true

provides :nagios_nginx
unified_mode true

action :create do
  node.default['nagios']['server']['web_server'] = 'nginx'

  nginx_install 'nagios' do
    source platform_family?('rhel') ? 'epel' : 'distro'
    ohai_plugin_enabled false
  end

  nginx_config 'nagios' do
    default_site_enabled false
    notifies :restart, 'nginx_service[nagios]', :delayed
  end

  php_install 'nagios'

  php_fpm_pool 'nagios' do
    user nagios_nginx_user
    group nagios_nginx_group
    listen_user nagios_nginx_user
    listen_group nagios_nginx_group
  end

  package nagios_array(node['nagios']['server']['nginx_dispatch']['packages'])

  if platform_family?('rhel')
    template '/etc/sysconfig/spawn-fcgi' do
      cookbook 'nagios'
      source 'spawn-fcgi.erb'
      notifies :start, 'service[spawn-fcgi]', :delayed
      variables(nginx_user: nagios_nginx_user)
    end
  end

  nagios_array(node['nagios']['server']['nginx_dispatch']['services']).each do |svc|
    service svc do
      action [:enable, :start]
    end
  end

  dispatch_type = node['nagios']['server']['nginx_dispatch']['type']

  nginx_site 'nagios' do
    template 'nginx.conf.erb'
    cookbook 'nagios'
    variables(
      allowed_ips: node['nagios']['allowed_ips'],
      cgi: %w(cgi both).include?(dispatch_type),
      cgi_bin_dir: platform_family?('rhel') ? '/usr/lib64' : '/usr/lib',
      chef_env: node.chef_environment == '_default' ? 'default' : node.chef_environment,
      docroot: node['nagios']['docroot'],
      fqdn: node['fqdn'],
      htpasswd_file: ::File.join(node['nagios']['conf_dir'], 'htpasswd.users'),
      https: node['nagios']['enable_ssl'],
      listen_port: node['nagios']['http_port'],
      log_dir: node['nagios']['log_dir'],
      nagios_url: node['nagios']['url'],
      nginx_dispatch_cgi_url: node['nagios']['server']['nginx_dispatch']['cgi_url'],
      nginx_dispatch_php_url: "unix:#{php_fpm_socket}",
      php: %w(php both).include?(dispatch_type),
      public_domain: node['public_domain'] || node['domain'],
      server_name: node['nagios']['server']['name'],
      server_vname: node['nagios']['server']['vname'],
      ssl_cert_file: node['nagios']['ssl_cert_file'],
      ssl_cert_key: node['nagios']['ssl_cert_key']
    )
    notifies :reload, 'nginx_service[nagios]', :delayed
    action [:create, :enable]
  end

  nginx_service 'nagios' do
    action :enable
    delayed_action :start
  end

  node.default['nagios']['web_user'] = nagios_nginx_user
  node.default['nagios']['web_group'] = nagios_nginx_user

  case node['nagios']['server_auth_method']
  when 'openid'
    raise 'OpenID authentication not supported on NGINX'
  when 'cas'
    raise 'CAS authentication not supported on NGINX'
  when 'ldap'
    raise 'LDAP authentication not supported on NGINX'
  end

  nagios_configure 'nagios'
end

action_class do
  include NagiosCookbook::Helpers
end
