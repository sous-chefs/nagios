module NagiosCookbook
  module Helpers
    def nagios_vname
      if platform_family?('rhel')
        'nagios'
      elsif platform?('debian')
        'nagios4'
      elsif platform?('ubuntu')
        case node['platform_version'].to_f
        when 16.04, 18.04
          'nagios3'
        when 20.04
          'nagios4'
        end
      end
    end

    def nagios_packages
      if platform_family?('rhel')
        %w(nagios nagios-plugins-nrpe)
      elsif platform?('debian')
        %w(nagios4 nagios-nrpe-plugin nagios-images)
      elsif platform?('ubuntu')
        case node['platform_version'].to_f
        when 16.04, 18.04
          %w(nagios3 nagios-nrpe-plugin nagios-images)
        when 20.04
          %w(nagios4 nagios-nrpe-plugin nagios-images)
        end
      end
    end

    def nagios_php_gd_package
      if platform_family?('rhel')
        'php-gd'
      elsif platform?('debian')
        'php7.3-gd'
      elsif platform?('ubuntu')
        case node['platform_version'].to_f
        when 16.04
          'php7.0-gd'
        when 18.04
          'php7.2-gd'
        when 20.04
          'php7.4-gd'
        end
      end
    end

    def nagios_server_dependencies
      if platform_family?('rhel')
        %w(openssl-devel gd-devel tar)
      elsif platform?('debian')
        %w(libssl-dev libgdchart-gd2-xpm-dev bsd-mailx tar)
      elsif platform?('ubuntu')
        case node['platform_version'].to_f
        when 16.04, 18.04
          %w(libssl-dev libgd2-xpm-dev bsd-mailx tar)
        when 20.04
          %w(libssl-dev libgd2-xpm-dev bsd-mailx tar)
        end
      end
    end

    def nagios_home
      if platform_family?('rhel')
        '/var/spool/nagios'
      else
        "/usr/lib/#{nagios_vname}"
      end
    end

    def nagios_conf_dir
      "/etc/#{nagios_vname}"
    end

    def nagios_config_dir
      "#{nagios_conf_dir}/conf.d"
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

    def nagios_install_method
      if platform_family?('rhel', 'debian')
        'package'
      else
        'source'
      end
    end
  end
end
Chef::Recipe.include ::NagiosCookbook::Helpers
Chef::Resource.include ::NagiosCookbook::Helpers
Chef::Node.include ::NagiosCookbook::Helpers
