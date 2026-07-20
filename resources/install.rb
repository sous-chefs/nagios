# frozen_string_literal: true

provides :nagios_install
unified_mode true

use '_partial/_settings'

action :install do
  case settings['server']['install_method']
  when 'package'
    install_package
  when 'source'
    install_source
  else
    raise "Unsupported Nagios installation method: #{settings['server']['install_method']}"
  end
end

action :remove do
  service settings['server']['service_name'] do
    action [:stop, :disable]
    ignore_failure true
  end

  if settings['server']['install_method'] == 'package'
    package settings['server']['packages'] do
      action :remove
    end
  else
    systemd_unit "#{settings['server']['service_name']}.service" do
      action [:stop, :disable, :delete]
    end

    file '/usr/sbin/nagios' do
      action :delete
    end

    file source_archive do
      action :delete
    end
  end

  [
    settings['config_dir'],
    settings['conf_dir'],
    settings['cache_dir'],
    settings['log_dir'],
    settings['run_dir'],
    settings['state_dir'],
    settings['docroot'],
    settings['cgi-bin'],
    "/usr/lib/#{settings['server']['vname']}",
  ].uniq.each do |path|
    directory path do
      recursive true
      action :delete
    end
  end
end

action_class do
  include NagiosCookbook::Helpers

  def settings
    new_resource.settings
  end

  def install_package
    case node['platform_family']
    when 'rhel'
      yum_epel 'default' if settings['server']['install_yum-epel']
    when 'debian'
      random_initial_password = rand(36**16).to_s(36)

      %w(adminpassword adminpassword-repeat).each do |setting|
        execute "debconf-set-selections::#{settings['server']['vname']}-cgi::#{settings['server']['vname']}/#{setting}" do
          command "echo #{settings['server']['vname']}-cgi #{settings['server']['vname']}/#{setting} password #{random_initial_password} | debconf-set-selections"
          sensitive true
          not_if "dpkg -l #{settings['server']['vname']}"
        end
      end
    end

    package settings['server']['packages']

    file "#{apache_dir}/conf-enabled/#{settings['server']['vname']}-cgi.conf" do
      manage_symlink_source true
      action :delete
    end

    file "#{apache_dir}/conf.d/nagios.conf" do
      action :delete
    end

    common_directories

    directory "/usr/lib/#{settings['server']['vname']}" do
      owner settings['user']
      group settings['group']
      mode '0755'
    end
  end

  def install_source
    build_essential 'install compilation tools'

    php_install 'nagios' do
      conf_dir nagios_php_conf_dir
    end

    package settings['php_gd_package']
    package settings['server']['dependencies']

    user settings['user'] do
      action :create
    end

    group settings['group'] do
      members [
        settings['user'],
        settings['server']['web_server'] == 'nginx' ? nagios_nginx_user : default_apache_user,
      ]
      action :create
    end

    settings['server']['patches'].each do |patch|
      remote_file "#{Chef::Config[:file_cache_path]}/#{patch}" do
        source "#{settings['server']['patch_url']}/#{patch}"
      end
    end

    remote_file 'nagios source file' do
      path source_archive
      source settings['server']['source_url']
      checksum settings['server']['checksum']
      notifies :run, 'execute[compile-nagios]', :immediately
    end

    execute 'compile-nagios' do
      cwd Chef::Config[:file_cache_path]
      command compile_command
      action :nothing
    end

    systemd_unit "#{settings['server']['service_name']}.service" do
      content(
        Unit: {
          Description: 'Nagios Core monitoring daemon',
          After: 'network.target',
        },
        Service: {
          Type: 'forking',
          User: settings['user'],
          Group: settings['group'],
          PIDFile: "#{settings['run_dir']}/#{settings['server']['vname']}.pid",
          ExecStart: "/usr/sbin/nagios -d #{settings['conf_dir']}/#{settings['server']['name']}.cfg",
          ExecReload: '/bin/kill -HUP $MAINPID',
          Restart: 'on-failure',
        },
        Install: {
          WantedBy: 'multi-user.target',
        }
      )
      action [:create, :enable]
    end

    common_directories

    directory "/usr/lib/#{settings['server']['vname']}" do
      owner settings['user']
      group settings['group']
      mode '0755'
    end
  end

  def common_directories
    directory settings['config_dir'] do
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
    end

    directory settings['conf']['check_result_path'] do
      owner settings['user']
      group settings['group']
      mode '0755'
      recursive true
    end

    %w(cache_dir log_dir run_dir).each do |dir|
      directory settings[dir] do
        recursive true
        owner settings['user']
        group settings['group']
        mode '0755'
      end
    end

    directory ::File.join(settings['log_dir'], 'archives') do
      owner settings['user']
      group settings['group']
      mode '0755'
    end
  end

  def compile_command
    <<~EOH
      tar xzf nagios-#{settings['server']['version']}.tar.gz
      cd nagios-#{settings['server']['version']}
      ./configure --prefix=/usr \\
          --mandir=/usr/share/man \\
          --bindir=/usr/sbin \\
          --sbindir=#{settings['cgi-bin']} \\
          --datadir=#{settings['docroot']} \\
          --sysconfdir=#{settings['conf_dir']} \\
          --infodir=/usr/share/info \\
          --libexecdir=#{settings['plugin_dir']} \\
          --localstatedir=#{settings['state_dir']} \\
          --with-cgibindir=#{settings['cgi-bin']} \\
          --enable-event-broker \\
          --with-nagios-user=#{settings['user']} \\
          --with-nagios-group=#{settings['group']} \\
          --with-command-user=#{settings['user']} \\
          --with-command-group=#{settings['group']} \\
          --with-lockfile=#{settings['run_dir']}/#{settings['server']['vname']}.pid \\
          --with-mail=/usr/bin/mail \\
          --with-perlcache \\
          --with-htmurl=/ \\
          --with-cgiurl=#{settings['cgi-path']}
      make all
      make install
      make install-cgis
      make install-config
      make install-commandmode
      #{settings['source']['add_build_commands'].join("\n")}
    EOH
  end

  def source_archive
    ::File.join(Chef::Config[:file_cache_path], "nagios-#{settings['server']['version']}.tar.gz")
  end
end
