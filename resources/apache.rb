# frozen_string_literal: true

provides :nagios_apache
unified_mode true

action :create do
  node.default['nagios']['server']['web_server'] = 'apache'

  php_install 'php' do
    conf_dir nagios_php_conf_dir
  end

  apache2_install 'nagios' do
    listen node['nagios']['enable_ssl'] ? %w(80 443) : %w(80)
    mpm node['nagios']['apache_mpm']
  end

  apache2_module 'cgi'
  apache2_module 'rewrite'

  apache_php_handler =
    if apache_mod_php_supported?
      apache2_mod_php 'nagios'
      'application/x-httpd-php'
    else
      apache2_module 'proxy'
      apache2_module 'proxy_fcgi'
      apache2_mod_proxy 'proxy'
      package nagios_php_fpm_package
      file nagios_php_fpm_default_conf do
        action :delete
      end
      php_fpm_pool 'nagios' do
        default_conf nagios_php_fpm_default_conf
        fpm_conf_dir nagios_php_fpm_conf_dir
        fpm_package nagios_php_fpm_package
        listen nagios_php_fpm_socket
        user default_apache_user
        group default_apache_group
        listen_user default_apache_user
        listen_group default_apache_group
        pool_dir nagios_php_fpm_pool_dir
        service nagios_php_fpm_service
      end
      "proxy:unix:#{nagios_php_fpm_socket}|fcgi://localhost"
    end

  apache2_module 'ssl' if node['nagios']['enable_ssl']

  apache2_site '000-default' do
    action :disable
    notifies :reload, 'apache2_service[nagios]'
  end

  template "#{apache_dir}/sites-available/#{node['nagios']['server']['vname']}.conf" do
    cookbook 'nagios'
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
    notifies :restart, 'apache2_service[nagios]' if ::File.symlink?("#{apache_dir}/sites-enabled/#{node['nagios']['server']['vname']}.conf")
  end

  file "#{apache_dir}/conf.d/#{node['nagios']['server']['vname']}.conf" do
    action :delete
  end

  apache2_site node['nagios']['server']['vname']

  node.default['nagios']['web_user'] = default_apache_user
  node.default['nagios']['web_group'] = default_apache_group

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

    %w(ldap authnz_ldap).each do |mod|
      apache2_module mod do
        notifies :reload, 'apache2_service[nagios]'
      end
    end
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

  nagios_configure 'nagios'
end

action_class do
  include NagiosCookbook::Helpers
end
