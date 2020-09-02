include NagiosCookbook::Helpers
include Apache2::Cookbook::Helpers

property :ssl, [true, false], default: false
property :http_port, Integer, default: 80
property :https_port, Integer, default: 443
property :mpm, String, default: 'prefork'
property :vname, String, default: lazy { nagios_vname }
property :url, String
property :ssl_cert_file, String, default: lazy { "#{nagios_config_dir}/certificates/nagios-server.pem" }
property :ssl_cert_key, String, default: lazy { "#{nagios_config_dir}/certificates/nagios-server.pem" }
property :server_auth_method, String, default: 'htauth'
property :config_dir, String,
         default: lazy { nagios_config_dir },
         description: 'Default location for the nagios configuration files'
property :vname_template_cookbook, String, default: 'nagios'
property :htauth_template_cookbook, String, default: 'nagios'

action :install do
  service 'apache2' do
    service_name apache_platform_service_name
    supports restart: true, status: true, reload: true
    action :nothing
  end

  apache2_install 'default-install' do
    listen new_resource.ssl ? [new_resource.http_port, new_resource.https_port] : [new_resource.http_port]
    mpm new_resource.mpm
  end

  apache2_mod_php
  apache2_module 'cgi'
  apache2_module 'rewrite'
  apache2_module 'ssl' if new_resource.ssl

  apache2_site '000-default' do
    action :disable
  end

  template "#{apache_dir}/sites-available/#{new_resource.vname}.conf" do
    cookbook new_resource.vname_template_cookbook
    source 'apache2.conf.erb'
    mode '0644'
    variables(
      nagios_url: new_resource.url,
      https: new_resource.ssl,
      ssl_cert_file: new_resource.ssl_cert_file,
      ssl_cert_key: new_resource.ssl_cert_key,
      apache_log_dir: default_log_dir
    )
    if ::File.symlink?("#{apache_dir}/sites-enabled/#{new_resource.vname}.conf")
      notifies :restart, 'service[apache2]'
    end
  end

  apache2_site new_resource.vname

  directory "#{nagios_conf_dir}/certificates" do
    owner default_apache_user
    group default_apache_group
    mode '0700'
  end

  case new_resource.server_auth_method
  when 'htauth'
    nagios_users = NagiosUsers.new(node, new_resource)
    template "#{new_resource.config_dir}/htpasswd.users" do
      cookbook new_resource.htauth_template_cookbook
      owner 'nagios'
      group default_apache_group
      mode '0640'
      sensitive true
      variables(nagios_users: nagios_users.users)
    end
  when 'openid'
    apache2_module 'auth_openid'
  when 'cas'
    apache2_module 'auth_cas'
  when 'ldap'
    apache2_module 'authnz_ldap'
  end
end

action_class do
  include NagiosCookbook::Helpers
  include Apache2::Cookbook::Helpers
end
