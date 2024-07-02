module NagiosCookbook
  module Helpers
    def nagios_vname
      if !node['nagios']['server'].nil? && node['nagios']['server']['install_method'] == 'source'
        'nagios'
      elsif platform_family?('rhel')
        'nagios'
      elsif platform?('debian')
        'nagios4'
      elsif platform?('ubuntu')
        'nagios4'
      end
    end

    def nagios_packages
      if platform_family?('rhel')
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
      elsif platform?('debian')
        case node['platform_version'].to_i
        when 11
          'php7.4-gd'
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

    def nagios_server_dependencies
      if platform_family?('rhel')
        %w(openssl-devel gd-devel tar unzip)
      else
        %w(libssl-dev libgdchart-gd2-xpm-dev bsd-mailx tar unzip)
      end
    end

    def nagios_nginx_dispatch_packages
      if platform_family?('rhel')
        %w(spawn-fcgi fcgiwrap)
      else
        %w(fcgiwrap)
      end
    end

    def nagios_nginx_dispatch_services
      if platform_family?('rhel')
        %w(spawn-fcgi)
      else
        %w(fcgiwrap)
      end
    end

    def nagios_nginx_user
      if platform_family?('rhel')
        'nginx'
      else
        'www-data'
      end
    end

    def nagios_nginx_group
      if platform_family?('rhel')
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
  end
end
Chef::DSL::Recipe.include ::NagiosCookbook::Helpers
Chef::Resource.include ::NagiosCookbook::Helpers
Chef::Node.include ::NagiosCookbook::Helpers
