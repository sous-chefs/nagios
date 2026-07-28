# frozen_string_literal: true

provides :nagios_nginx
unified_mode true

use '_partial/_settings'

property :users, [Array, nil], default: nil

action :create do
  nginx_install 'nagios' do
    source platform_family?('rhel') ? 'epel' : 'distro'
    ohai_plugin_enabled false
  end

  nginx_config 'nagios' do
    default_site_enabled false
    notifies :restart, 'nginx_service[nagios]', :delayed
  end

  php_install 'nagios' do
    conf_dir nagios_php_conf_dir
  end

  package nagios_php_fpm_package
  file nagios_php_fpm_default_conf do
    action :delete
  end

  php_fpm_pool 'nagios' do
    default_conf nagios_php_fpm_default_conf
    fpm_conf_dir nagios_php_fpm_conf_dir
    fpm_package nagios_php_fpm_package
    listen nagios_php_fpm_socket
    user nagios_nginx_user
    group nagios_nginx_group
    listen_user nagios_nginx_user
    listen_group nagios_nginx_group
    pool_dir nagios_php_fpm_pool_dir
    service nagios_php_fpm_service
  end

  package nagios_array(settings['server']['nginx_dispatch']['packages'])

  if nagios_array(settings['server']['nginx_dispatch']['services']).include?('spawn-fcgi')
    template '/etc/sysconfig/spawn-fcgi' do
      cookbook 'nagios'
      source 'spawn-fcgi.erb'
      notifies :start, 'service[spawn-fcgi]', :delayed
      variables(nginx_user: nagios_nginx_user, settings: settings)
    end
  end

  nagios_array(settings['server']['nginx_dispatch']['services']).each do |svc|
    service svc do
      action [:enable, :start]
    end
  end

  dispatch_type = settings['server']['nginx_dispatch']['type']

  nginx_site 'nagios' do
    template 'nginx.conf.erb'
    cookbook 'nagios'
    variables(
      settings: settings,
      allowed_ips: settings['allowed_ips'],
      cgi: %w(cgi both).include?(dispatch_type),
      cgi_bin_dir: platform_family?('rhel', 'fedora') ? '/usr/lib64' : '/usr/lib',
      chef_env: node.chef_environment == '_default' ? 'default' : node.chef_environment,
      docroot: settings['docroot'],
      fqdn: node['fqdn'],
      htpasswd_file: ::File.join(settings['conf_dir'], 'htpasswd.users'),
      https: settings['enable_ssl'],
      listen_port: settings['http_port'],
      log_dir: settings['log_dir'],
      nagios_url: settings['url'],
      nginx_dispatch_cgi_url: settings['server']['nginx_dispatch']['cgi_url'],
      nginx_dispatch_php_url: "unix:#{nagios_php_fpm_socket}",
      php: %w(php both).include?(dispatch_type),
      public_domain: node['public_domain'] || node['domain'],
      server_name: settings['server']['name'],
      server_vname: settings['server']['vname'],
      ssl_cert_file: settings['ssl_cert_file'],
      ssl_cert_key: settings['ssl_cert_key']
    )
    notifies :reload, 'nginx_service[nagios]', :delayed
    action [:create, :enable]
  end

  nginx_service 'nagios' do
    action :enable
    delayed_action :start
  end

  case settings['server_auth_method']
  when 'openid'
    raise 'OpenID authentication not supported on NGINX'
  when 'cas'
    raise 'CAS authentication not supported on NGINX'
  when 'ldap'
    raise 'LDAP authentication not supported on NGINX'
  end

  nagios_configure 'nagios' do
    settings new_resource.settings
    users new_resource.users
  end
end

action :delete do
  nginx_site 'nagios' do
    action [:disable, :delete]
  end

  nagios_array(settings['server']['nginx_dispatch']['services']).each do |svc|
    service svc do
      action [:stop, :disable]
      ignore_failure true
    end
  end

  file '/etc/sysconfig/spawn-fcgi' do
    action :delete
  end

  nagios_configure 'nagios' do
    settings new_resource.settings
    action :delete
  end

  nagios_install 'nagios' do
    settings new_resource.settings
    action :remove
  end
end

action_class do
  include NagiosCookbook::Helpers

  def settings
    new_resource.settings
  end
end
