# frozen_string_literal: true

provides :nagios_server
unified_mode true

property :config, Hash, default: {}
property :cgi_config, Hash, default: {}
property :default_host, Hash, default: {}
property :default_service, Hash, default: {}
property :templates, Hash, default: {}
property :brokers, Hash, default: {}

property :install_method, String
property :web_server, String, equal_to: %w(apache nginx none), default: 'apache'
property :nagios_name, String, default: 'nagios'
property :server_vname, String
property :service_name, String
property :server_name, String
property :server_alias, [String, nil]
property :url, [String, nil]
property :enable_ssl, [true, false], default: false
property :http_port, [String, Integer, nil], default: nil
property :ssl_cert_file, [String, nil]
property :ssl_cert_key, [String, nil]
property :ssl_cert_chain_file, [String, nil]
property :ssl_req, [String, nil]
property :ssl_protocols, String, default: 'all -SSLv3 -SSLv2'
property :ssl_ciphers, [String, nil]
property :apache_mpm, String, default: 'prefork'

property :nagios_user, String, default: 'nagios'
property :nagios_group, String, default: 'nagios'
property :web_user, [String, nil]
property :web_group, [String, nil]
property :home, [String, nil]
property :conf_dir, [String, nil]
property :resource_dir, [String, nil]
property :config_dir, [String, nil]
property :log_dir, [String, nil]
property :cache_dir, [String, nil]
property :state_dir, [String, nil]
property :run_dir, [String, nil]
property :docroot, [String, nil]
property :cgi_bin, [String, nil]
property :cgi_path, [String, nil]
property :plugin_dir, [String, nil]

property :package_names, [Array, nil], default: nil
property :install_yum_epel, [true, false], default: true
property :php_gd_package, [String, nil]
property :source_version, String, default: '4.4.6'
property :source_checksum, String, default: 'ab0d5a52caf01e6f4dcd84252c4eb5df5a24f90bb7f951f03875eef54f5ab0f4'
property :source_url, [String, nil]
property :source_patch_url, [String, nil]
property :source_patches, Array, default: []
property :source_dependencies, [Array, nil], default: nil
property :source_add_build_commands, Array, default: ['make install-exfoliation']

property :multi_environment_monitoring, [true, false], default: false
property :monitored_environments, Array, default: []
property :monitoring_interface, [String, nil]
property :exclude_tag_host, [String, Array], default: ''
property :host_name_attribute, String, default: 'hostname'
property :regexp_matching, Integer, default: 0
property :host_template, String, default: 'server'
property :normalize_hostname, [true, false], default: false

property :server_auth_method, String, default: 'htauth'
property :server_auth_require, String, default: 'valid-user'
property :default_contact_groups, Array, default: %w(admins)
property :default_user_name, [String, nil]
property :sysadmin_email, String, default: 'root@localhost'
property :sysadmin_sms_email, String, default: 'root@localhost'
property :check_external_commands, [true, false], default: true
property :allowed_ips, Array, default: []

property :users, [Array, nil], default: nil
property :users_databag, String, default: 'users'
property :users_databag_group, String, default: 'sysadmin'
property :services_databag, String, default: 'nagios_services'
property :servicegroups_databag, String, default: 'nagios_servicegroups'
property :templates_databag, String, default: 'nagios_templates'
property :hosttemplates_databag, String, default: 'nagios_hosttemplates'
property :eventhandlers_databag, String, default: 'nagios_eventhandlers'
property :unmanagedhosts_databag, String, default: 'nagios_unmanagedhosts'
property :serviceescalations_databag, String, default: 'nagios_serviceescalations'
property :hostgroups_databag, String, default: 'nagios_hostgroups'
property :hostescalations_databag, String, default: 'nagios_hostescalations'
property :contacts_databag, String, default: 'nagios_contacts'
property :contactgroups_databag, String, default: 'nagios_contactgroups'
property :servicedependencies_databag, String, default: 'nagios_servicedependencies'
property :timeperiods_databag, String, default: 'nagios_timeperiods'
property :load_default_config, [true, false], default: true
property :load_databag_config, [true, false], default: true
property :use_encrypted_data_bags, [true, false], default: false

property :htauth_template_cookbook, String, default: 'nagios'
property :htauth_template_file, String, default: 'htpasswd.users.erb'
property :nagios_config_template_cookbook, String, default: 'nagios'
property :nagios_config_template_file, String, default: 'nagios.cfg.erb'
property :resource_template_cookbook, String, default: 'nagios'
property :resource_template_file, String, default: 'resource.cfg.erb'
property :cgi_template_cookbook, String, default: 'nagios'
property :cgi_template_file, String, default: 'cgi.cfg.erb'

property :nginx_dispatch_type, String, equal_to: %w(cgi php both), default: 'both'
property :nginx_dispatch_packages, [Array, nil], default: nil
property :nginx_dispatch_services, [Array, nil], default: nil
property :nginx_dispatch_cgi_url, [String, nil]
property :stop_apache, [true, false], default: false

property :mail_command, [String, nil]
property :pagerduty_key, [String, nil]
property :pagerduty_script_url, String, default: 'https://raw.github.com/PagerDuty/pagerduty-nagios-pl/master/pagerduty_nagios.pl'
property :pagerduty_service_notification_options, String, default: 'w,u,c,r'
property :pagerduty_host_notification_options, String, default: 'd,r'
property :pagerduty_proxy_url, [String, nil]

action :create do
  settings = nagios_default_settings(new_resource)
  settings['conf'] = nagios_default_conf(settings)
  node.default['nagios'] = settings

  case settings['server']['web_server']
  when 'apache'
    nagios_apache 'nagios' do
      users new_resource.users
    end
  when 'nginx'
    nagios_nginx 'nagios' do
      users new_resource.users
    end
  when 'none'
    nagios_install 'nagios'
    nagios_configure 'nagios' do
      users new_resource.users
    end
  end
end

action_class do
  include NagiosCookbook::Helpers
end
