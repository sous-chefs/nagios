# frozen_string_literal: true

module NagiosCookbook
  module Helpers
    def nagios_vname(install_method = nil)
      if install_method == 'source' ||
         (!node['nagios'].nil? && !node['nagios']['server'].nil? && node['nagios']['server']['install_method'] == 'source')
        'nagios'
      elsif platform_family?('rhel', 'fedora')
        'nagios'
      elsif platform?('debian')
        'nagios4'
      elsif platform?('ubuntu')
        'nagios4'
      end
    end

    def nagios_packages
      if platform_family?('rhel', 'fedora')
        %w(nagios nagios-plugins-nrpe)
      elsif platform?('debian')
        %w(nagios4 nagios-nrpe-plugin nagios-images)
      elsif platform?('ubuntu')
        %w(nagios4 nagios-nrpe-plugin nagios-images)
      end
    end

    def nagios_php_gd_package
      if platform_family?('rhel')
        'php-gd'
      elsif platform_family?('fedora')
        'php-gd'
      elsif platform?('debian')
        case node['platform_version'].to_i
        when 11
          'php7.4-gd'
        when 13
          'php8.4-gd'
        else
          'php8.2-gd'
        end
      elsif platform?('ubuntu')
        case node['platform_version'].to_f
        when 20.04
          'php7.4-gd'
        when 22.04
          'php8.1-gd'
        else
          'php8.3-gd'
        end
      end
    end

    def nagios_php_version
      if platform?('debian')
        case node['platform_version'].to_i
        when 11
          '7.4'
        when 13
          '8.4'
        else
          '8.2'
        end
      elsif platform?('ubuntu')
        case node['platform_version'].to_f
        when 20.04
          '7.4'
        when 22.04
          '8.1'
        else
          '8.3'
        end
      elsif platform_family?('rhel')
        node['platform_version'].to_i >= 9 ? '8.0' : '7.2'
      elsif platform_family?('fedora')
        node['platform_version'].to_i >= 44 ? '8.5' : '8.3'
      end
    end

    def nagios_php_conf_dir
      if platform_family?('rhel', 'fedora')
        '/etc'
      else
        "/etc/php/#{nagios_php_version}/cli"
      end
    end

    def nagios_php_fpm_conf_dir
      if platform_family?('rhel', 'fedora')
        '/etc/php-fpm.d'
      else
        "/etc/php/#{nagios_php_version}/fpm"
      end
    end

    def nagios_php_fpm_default_conf
      if platform_family?('rhel', 'fedora')
        '/etc/php-fpm.d/www.conf'
      else
        "#{nagios_php_fpm_pool_dir}/www.conf"
      end
    end

    def nagios_php_fpm_package
      if platform_family?('rhel', 'fedora')
        'php-fpm'
      else
        "php#{nagios_php_version}-fpm"
      end
    end

    def nagios_php_fpm_pool_dir
      if platform_family?('rhel', 'fedora')
        '/etc/php-fpm.d'
      else
        "/etc/php/#{nagios_php_version}/fpm/pool.d"
      end
    end

    def nagios_php_fpm_service
      if platform_family?('rhel', 'fedora')
        'php-fpm'
      else
        "php#{nagios_php_version}-fpm"
      end
    end

    def nagios_php_fpm_socket
      if platform_family?('rhel', 'fedora')
        "/var/run/php#{nagios_php_version}-fpm.sock"
      else
        "/var/run/php/php#{nagios_php_version}-fpm.sock"
      end
    end

    def nagios_server_dependencies
      if platform_family?('rhel', 'fedora')
        %w(openssl-devel gd-devel tar unzip)
      else
        %w(libssl-dev libgdchart-gd2-xpm-dev bsd-mailx tar unzip)
      end
    end

    def nagios_nginx_dispatch_packages
      if platform_family?('rhel') && node['platform_version'].to_i < 9
        %w(spawn-fcgi fcgiwrap)
      elsif platform_family?('rhel', 'fedora')
        %w(fcgiwrap)
      else
        %w(fcgiwrap)
      end
    end

    def nagios_nginx_dispatch_services
      if platform_family?('rhel') && node['platform_version'].to_i < 9
        %w(spawn-fcgi)
      elsif platform_family?('rhel', 'fedora')
        %w(fcgiwrap@nginx.socket)
      else
        %w(fcgiwrap)
      end
    end

    def nagios_nginx_dispatch_cgi_url
      if platform_family?('rhel') && node['platform_version'].to_i >= 9
        'unix:/run/fcgiwrap/fcgiwrap-nginx.sock'
      elsif platform_family?('fedora')
        'unix:/run/fcgiwrap/fcgiwrap-nginx.sock'
      else
        'unix:/var/run/fcgiwrap.socket'
      end
    end

    def nagios_nginx_user
      if platform_family?('rhel', 'fedora')
        'nginx'
      else
        'www-data'
      end
    end

    def nagios_nginx_group
      if platform_family?('rhel', 'fedora')
        'nginx'
      else
        'www-data'
      end
    end

    def nagios_home
      if platform_family?('rhel')
        '/var/spool/nagios'
      else
        "/usr/lib/#{nagios_vname}"
      end
    end

    def nagios_plugin_dir
      case node['platform_family']
      when 'debian'
        '/usr/lib/nagios/plugins'
      when 'rhel'
        node['kernel']['machine'] == 'i686' ? '/usr/lib/nagios/plugins' : '/usr/lib64/nagios/plugins'
      else
        '/usr/lib/nagios/plugins'
      end
    end

    def nagios_conf_dir
      "/etc/#{nagios_vname}"
    end

    def nagios_config_dir
      "#{nagios_conf_dir}/conf.d"
    end

    def nagios_distro_config_dir
      if platform_family?('rhel')
        "#{nagios_conf_dir}/objects"
      else
        "#{nagios_conf_dir}/dist"
      end
    end

    def nagios_log_dir
      "/var/log/#{nagios_vname}"
    end

    def nagios_cache_dir
      if platform_family?('rhel')
        '/var/log/nagios'
      else
        "/var/cache/#{nagios_vname}"
      end
    end

    def nagios_state_dir
      if platform_family?('rhel')
        '/var/log/nagios'
      else
        "/var/lib/#{nagios_vname}"
      end
    end

    def nagios_run_dir
      if platform_family?('rhel')
        if platform?('centos') && node['platform_version'].to_i < 7
          '/var/run'
        else
          '/var/run/nagios'
        end
      else
        "/var/run/#{nagios_vname}"
      end
    end

    def nagios_docroot
      if platform_family?('rhel')
        '/usr/share/nagios/html'
      else
        "/usr/share/#{nagios_vname}/htdocs"
      end
    end

    def nagios_cgi_bin
      if platform_family?('rhel')
        '/usr/lib64/nagios/cgi-bin/'
      else
        "/usr/lib/cgi-bin/#{nagios_vname}"
      end
    end

    def nagios_service_name
      nagios_vname
    end

    def nagios_mail_command
      if platform_family?('rhel')
        '/bin/mail'
      else
        '/usr/bin/mail'
      end
    end

    def nagios_cgi_path
      if platform_family?('rhel')
        '/nagios/cgi-bin/'
      else
        "/cgi-bin/#{nagios_service_name}"
      end
    end

    def nagios_check_result_path
      if platform?('centos') && node['platform_version'].to_i >= 7
        "#{nagios_home}/checkresults"
      else
        "#{nagios_state_dir}/spool/checkresults"
      end
    end

    def nagios_conf_p1_file
      case node['platform_family']
      when 'debian'
        "#{nagios_home}/p1.pl"
      when 'rhel'
        '/usr/sbin/p1.pl'
      else
        "#{nagios_home}/p1.pl"
      end
    end

    def nagios_install_method
      if platform_family?('rhel', 'debian')
        'package'
      else
        'source'
      end
    end

    def nagios_pagerduty_packages
      case node['platform_family']
      when 'rhel'
        %w(perl-CGI perl-JSON perl-libwww-perl perl-Sys-Syslog)
      when 'debian'
        %w(libcgi-pm-perl libjson-perl libwww-perl)
      end
    end

    def nagios_default_settings(resource)
      vname = resource.server_vname || nagios_vname(resource.install_method || nagios_install_method)
      server_name = resource.server_name || node['fqdn']
      conf_dir = resource.conf_dir || "/etc/#{vname}"
      config_dir = resource.config_dir || "#{conf_dir}/conf.d"
      log_dir = resource.log_dir || "/var/log/#{vname}"
      cache_dir = resource.cache_dir || (platform_family?('rhel', 'fedora') ? '/var/log/nagios' : "/var/cache/#{vname}")
      state_dir = resource.state_dir || (platform_family?('rhel', 'fedora') ? '/var/log/nagios' : "/var/lib/#{vname}")
      run_dir = resource.run_dir || (platform_family?('rhel', 'fedora') ? '/var/run/nagios' : "/var/run/#{vname}")
      home = resource.home || (platform_family?('rhel', 'fedora') ? '/var/spool/nagios' : "/usr/lib/#{vname}")
      docroot = resource.docroot || (platform_family?('rhel', 'fedora') ? '/usr/share/nagios/html' : "/usr/share/#{vname}/htdocs")
      cgi_bin = resource.cgi_bin || (platform_family?('rhel', 'fedora') ? '/usr/lib64/nagios/cgi-bin/' : "/usr/lib/cgi-bin/#{vname}")
      install_method = resource.install_method || nagios_install_method

      defaults = {
        'multi_environment_monitoring' => resource.multi_environment_monitoring,
        'monitored_environments' => resource.monitored_environments,
        'user' => resource.nagios_user,
        'group' => resource.nagios_group,
        'web_user' => resource.web_user || resource.nagios_user,
        'web_group' => resource.web_group || resource.nagios_group,
        'monitoring_interface' => resource.monitoring_interface,
        'htauth' => {
          'template_cookbook' => resource.htauth_template_cookbook,
          'template_file' => resource.htauth_template_file,
        },
        'nagios_config' => {
          'template_cookbook' => resource.nagios_config_template_cookbook,
          'template_file' => resource.nagios_config_template_file,
        },
        'resources' => {
          'template_cookbook' => resource.resource_template_cookbook,
          'template_file' => resource.resource_template_file,
        },
        'cgi' => nagios_default_cgi_config.merge(
          'template_cookbook' => resource.cgi_template_cookbook,
          'template_file' => resource.cgi_template_file
        ).merge(resource.cgi_config),
        'plugin_dir' => resource.plugin_dir || nagios_plugin_dir,
        'home' => home,
        'conf_dir' => conf_dir,
        'resource_dir' => resource.resource_dir || conf_dir,
        'config_dir' => config_dir,
        'log_dir' => log_dir,
        'cache_dir' => cache_dir,
        'state_dir' => state_dir,
        'run_dir' => run_dir,
        'docroot' => docroot,
        'cgi-bin' => cgi_bin,
        'cgi-path' => resource.cgi_path || (platform_family?('rhel', 'fedora') ? '/nagios/cgi-bin/' : "/cgi-bin/#{vname}"),
        'enable_ssl' => resource.enable_ssl,
        'http_port' => resource.http_port || (resource.enable_ssl ? '443' : '80'),
        'server_name' => server_name,
        'url' => resource.url,
        'ssl_cert_file' => resource.ssl_cert_file || "#{conf_dir}/certificates/nagios-server.pem",
        'ssl_cert_key' => resource.ssl_cert_key || "#{conf_dir}/certificates/nagios-server.pem",
        'ssl_cert_chain_file' => resource.ssl_cert_chain_file,
        'ssl_req' => resource.ssl_req || "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{server_name}/emailAddress=ops@#{server_name}",
        'ssl_protocols' => resource.ssl_protocols,
        'ssl_ciphers' => resource.ssl_ciphers,
        'check_external_commands' => resource.check_external_commands,
        'default_contact_groups' => resource.default_contact_groups,
        'default_user_name' => resource.default_user_name,
        'sysadmin_email' => resource.sysadmin_email,
        'sysadmin_sms_email' => resource.sysadmin_sms_email,
        'server_auth_method' => resource.server_auth_method,
        'server_auth_require' => resource.server_auth_require,
        'users_databag' => resource.users_databag,
        'users_databag_group' => resource.users_databag_group,
        'services_databag' => resource.services_databag,
        'servicegroups_databag' => resource.servicegroups_databag,
        'templates_databag' => resource.templates_databag,
        'hosttemplates_databag' => resource.hosttemplates_databag,
        'eventhandlers_databag' => resource.eventhandlers_databag,
        'unmanagedhosts_databag' => resource.unmanagedhosts_databag,
        'serviceescalations_databag' => resource.serviceescalations_databag,
        'hostgroups_databag' => resource.hostgroups_databag,
        'hostescalations_databag' => resource.hostescalations_databag,
        'contacts_databag' => resource.contacts_databag,
        'contactgroups_databag' => resource.contactgroups_databag,
        'servicedependencies_databag' => resource.servicedependencies_databag,
        'timeperiods_databag' => resource.timeperiods_databag,
        'host_name_attribute' => resource.host_name_attribute,
        'regexp_matching' => resource.regexp_matching,
        'host_template' => resource.host_template,
        'templates' => resource.templates,
        'default_host' => nagios_default_host_config.merge(resource.default_host),
        'default_service' => nagios_default_service_config.merge(resource.default_service),
        'brokers' => resource.brokers,
        'exclude_tag_host' => resource.exclude_tag_host,
        'apache_mpm' => resource.apache_mpm,
        'source' => {
          'add_build_commands' => resource.source_add_build_commands,
        },
        'allowed_ips' => resource.allowed_ips,
        'php_gd_package' => resource.php_gd_package || nagios_php_gd_package,
        'pagerduty' => {
          'script_url' => resource.pagerduty_script_url,
          'service_notification_options' => resource.pagerduty_service_notification_options,
          'host_notification_options' => resource.pagerduty_host_notification_options,
          'proxy_url' => resource.pagerduty_proxy_url,
          'key' => resource.pagerduty_key,
        },
        'server' => {
          'install_method' => install_method,
          'service_name' => resource.service_name || vname,
          'mail_command' => resource.mail_command || nagios_mail_command,
          'web_server' => resource.web_server,
          'server_alias' => resource.server_alias,
          'name' => resource.nagios_name,
          'vname' => vname,
          'version' => resource.source_version,
          'checksum' => resource.source_checksum,
          'source_url' => resource.source_url || "https://assets.nagios.com/downloads/nagioscore/releases/nagios-#{resource.source_version}.tar.gz",
          'patches' => resource.source_patches,
          'patch_url' => resource.source_patch_url,
          'dependencies' => resource.source_dependencies || nagios_server_dependencies,
          'packages' => resource.package_names || nagios_packages,
          'install_yum-epel' => resource.install_yum_epel,
          'stop_apache' => resource.stop_apache,
          'normalize_hostname' => resource.normalize_hostname,
          'load_default_config' => resource.load_default_config,
          'load_databag_config' => resource.load_databag_config,
          'use_encrypted_data_bags' => resource.use_encrypted_data_bags,
          'nginx_dispatch' => {
            'type' => resource.nginx_dispatch_type,
            'packages' => resource.nginx_dispatch_packages || nagios_nginx_dispatch_packages,
            'services' => resource.nginx_dispatch_services || nagios_nginx_dispatch_services,
            'cgi_url' => resource.nginx_dispatch_cgi_url || nagios_nginx_dispatch_cgi_url,
          },
        },
      }

      deep_merge(defaults, resource.config)
    end

    def nagios_default_cgi_config
      {
        'show_context_help' => 1,
        'authorized_for_system_information' => '*',
        'authorized_for_configuration_information' => '*',
        'authorized_for_system_commands' => '*',
        'authorized_for_all_services' => '*',
        'authorized_for_all_hosts' => '*',
        'authorized_for_all_service_commands' => '*',
        'authorized_for_all_host_commands' => '*',
        'default_statusmap_layout' => 5,
        'default_statuswrl_layout' => 4,
        'result_limit' => 100,
        'escape_html_tags' => 0,
        'action_url_target' => '_blank',
        'notes_url_target' => '_blank',
        'lock_author_names' => 1,
      }
    end

    def nagios_default_host_config
      {
        'flap_detection' => true,
        'process_perf_data' => false,
        'check_period' => '24x7',
        'check_interval' => 15,
        'retry_interval' => 15,
        'max_check_attempts' => 1,
        'check_command' => 'check_host_alive',
        'notification_interval' => 300,
        'notification_options' => 'd,u,r',
        'action_url' => nil,
      }
    end

    def nagios_default_service_config
      {
        'check_interval' => 60,
        'process_perf_data' => false,
        'retry_interval' => 15,
        'max_check_attempts' => 3,
        'notification_interval' => 1200,
        'flap_detection' => true,
        'action_url' => nil,
      }
    end

    def nagios_default_conf(settings)
      server_name = settings['server']['name']
      server_vname = settings['server']['vname']
      cache_dir = settings['cache_dir']
      conf_dir = settings['conf_dir']
      config_dir = settings['config_dir']
      log_dir = settings['log_dir']
      run_dir = settings['run_dir']
      state_dir = settings['state_dir']

      {
        'log_file' => "#{log_dir}/#{server_name}.log",
        'cfg_dir' => config_dir,
        'object_cache_file' => "#{cache_dir}/objects.cache",
        'precached_object_file' => "#{cache_dir}/objects.precache",
        'resource_file' => "#{conf_dir}/resource.cfg",
        'temp_file' => "#{cache_dir}/#{server_name}.tmp",
        'temp_path' => '/tmp',
        'status_file' => "#{cache_dir}/status.dat",
        'status_update_interval' => '10',
        'nagios_user' => settings['user'],
        'nagios_group' => settings['group'],
        'enable_notifications' => '1',
        'execute_service_checks' => '1',
        'accept_passive_service_checks' => '1',
        'execute_host_checks' => '1',
        'accept_passive_host_checks' => '1',
        'enable_event_handlers' => '1',
        'log_rotation_method' => 'd',
        'log_archive_path' => "#{log_dir}/archives",
        'check_external_commands' => '1',
        'command_check_interval' => '-1',
        'command_file' => "#{state_dir}/rw/#{server_name}.cmd",
        'external_command_buffer_slots' => '4096',
        'check_for_updates' => '0',
        'lock_file' => "#{run_dir}/#{server_vname}.pid",
        'retain_state_information' => '1',
        'state_retention_file' => "#{state_dir}/retention.dat",
        'retention_update_interval' => '60',
        'use_retained_program_state' => '1',
        'use_retained_scheduling_info' => '1',
        'use_syslog' => '1',
        'log_notifications' => '1',
        'log_service_retries' => '1',
        'log_host_retries' => '1',
        'log_event_handlers' => '1',
        'log_initial_states' => '0',
        'log_external_commands' => '1',
        'log_passive_checks' => '1',
        'sleep_time' => '1',
        'service_inter_check_delay_method' => 's',
        'max_service_check_spread' => '5',
        'service_interleave_factor' => 's',
        'max_concurrent_checks' => '0',
        'check_result_reaper_frequency' => '10',
        'max_check_result_reaper_time' => '30',
        'check_result_path' => platform?('centos') && node['platform_version'].to_i >= 7 ? "#{settings['home']}/checkresults" : "#{state_dir}/spool/checkresults",
        'max_check_result_file_age' => '3600',
        'host_inter_check_delay_method' => 's',
        'max_host_check_spread' => '5',
        'interval_length' => '1',
        'auto_reschedule_checks' => '0',
        'auto_rescheduling_interval' => '30',
        'auto_rescheduling_window' => '180',
        'use_aggressive_host_checking' => '0',
        'translate_passive_host_checks' => '0',
        'passive_host_checks_are_soft' => '0',
        'enable_predictive_host_dependency_checks' => '1',
        'enable_predictive_service_dependency_checks' => '1',
        'cached_host_check_horizon' => '15',
        'cached_service_check_horizon' => '15',
        'use_large_installation_tweaks' => '0',
        'enable_environment_macros' => '1',
        'enable_flap_detection' => '1',
        'low_service_flap_threshold' => '5.0',
        'high_service_flap_threshold' => '20.0',
        'low_host_flap_threshold' => '5.0',
        'high_host_flap_threshold' => '20.0',
        'soft_state_dependencies' => '0',
        'service_check_timeout' => '60',
        'host_check_timeout' => '30',
        'event_handler_timeout' => '30',
        'notification_timeout' => '30',
        'ocsp_timeout' => '5',
        'ochp_timeout' => '5',
        'perfdata_timeout' => '5',
        'obsess_over_services' => '0',
        'obsess_over_hosts' => '0',
        'process_performance_data' => '0',
        'check_for_orphaned_services' => '1',
        'check_for_orphaned_hosts' => '1',
        'check_service_freshness' => '1',
        'service_freshness_check_interval' => '60',
        'check_host_freshness' => '0',
        'host_freshness_check_interval' => '60',
        'additional_freshness_latency' => '15',
        'enable_embedded_perl' => '1',
        'use_embedded_perl_implicitly' => '1',
        'date_format' => 'iso8601',
        'use_timezone' => 'UTC',
        'illegal_object_name_chars' => '`~!$%^&*|\\\'"<>?,()=',
        'illegal_macro_output_chars' => '`~$&|\\\'"<>#',
        'use_regexp_matching' => '0',
        'use_true_regexp_matching' => '0',
        'admin_email' => settings['sysadmin_email'],
        'admin_pager' => settings['sysadmin_sms_email'],
        'event_broker_options' => '-1',
        'retained_host_attribute_mask' => '0',
        'retained_service_attribute_mask' => '0',
        'retained_process_host_attribute_mask' => '0',
        'retained_process_service_attribute_mask' => '0',
        'retained_contact_host_attribute_mask' => '0',
        'retained_contact_service_attribute_mask' => '0',
        'daemon_dumps_core' => '0',
        'debug_file' => "#{state_dir}/#{server_name}.debug",
        'debug_level' => '0',
        'debug_verbosity' => '1',
        'max_debug_file_size' => '1000000',
        'allow_empty_hostgroup_assignment' => '1',
        'service_check_timeout_state' => 'c',
        'p1_file' => settings['server']['install_method'] == 'source' ? nil : nagios_conf_p1_file,
      }.merge(settings.fetch('conf', {}))
    end

    def deep_merge(left, right)
      left.merge(right) do |_key, old_value, new_value|
        old_value.is_a?(Hash) && new_value.is_a?(Hash) ? deep_merge(old_value, new_value) : new_value
      end
    end
  end
end
