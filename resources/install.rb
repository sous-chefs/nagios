# frozen_string_literal: true

provides :nagios_install
unified_mode true

action :install do
  case node['nagios']['server']['install_method']
  when 'package'
    install_package
  when 'source'
    install_source
  else
    raise "Unsupported Nagios installation method: #{node['nagios']['server']['install_method']}"
  end
end

action_class do
  include NagiosCookbook::Helpers

  def install_package
    case node['platform_family']
    when 'rhel'
      include_recipe 'yum-epel' if node['nagios']['server']['install_yum-epel']
    when 'debian'
      random_initial_password = rand(36**16).to_s(36)

      %w(adminpassword adminpassword-repeat).each do |setting|
        execute "debconf-set-selections::#{node['nagios']['server']['vname']}-cgi::#{node['nagios']['server']['vname']}/#{setting}" do
          command "echo #{node['nagios']['server']['vname']}-cgi #{node['nagios']['server']['vname']}/#{setting} password #{random_initial_password} | debconf-set-selections"
          sensitive true
          not_if "dpkg -l #{node['nagios']['server']['vname']}"
        end
      end
    end

    package node['nagios']['server']['packages']

    file "#{apache_dir}/conf-enabled/#{node['nagios']['server']['vname']}-cgi.conf" do
      manage_symlink_source true
      action :delete
    end

    file "#{apache_dir}/conf.d/nagios.conf" do
      action :delete
    end

    common_directories

    directory "/usr/lib/#{node['nagios']['server']['vname']}" do
      owner node['nagios']['user']
      group node['nagios']['group']
      mode '0755'
    end
  end

  def install_source
    build_essential 'install compilation tools'

    php_install 'nagios' do
      conf_dir nagios_php_conf_dir
    end

    package node['nagios']['php_gd_package']
    package node['nagios']['server']['dependencies']

    user node['nagios']['user'] do
      action :create
    end

    group node['nagios']['group'] do
      members [
        node['nagios']['user'],
        node['nagios']['server']['web_server'] == 'nginx' ? nagios_nginx_user : default_apache_user,
      ]
      action :create
    end

    node['nagios']['server']['patches'].each do |patch|
      remote_file "#{Chef::Config[:file_cache_path]}/#{patch}" do
        source "#{node['nagios']['server']['patch_url']}/#{patch}"
      end
    end

    remote_file 'nagios source file' do
      path ::File.join(Chef::Config[:file_cache_path], "nagios-#{node['nagios']['server']['version']}.tar.gz")
      source node['nagios']['server']['source_url']
      checksum node['nagios']['server']['checksum']
      notifies :run, 'execute[compile-nagios]', :immediately
    end

    execute 'compile-nagios' do
      cwd Chef::Config[:file_cache_path]
      command compile_command
      action :nothing
    end

    common_directories

    directory "/usr/lib/#{node['nagios']['server']['vname']}" do
      owner node['nagios']['user']
      group node['nagios']['group']
      mode '0755'
    end
  end

  def common_directories
    directory node['nagios']['config_dir'] do
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
    end

    directory node['nagios']['conf']['check_result_path'] do
      owner node['nagios']['user']
      group node['nagios']['group']
      mode '0755'
      recursive true
    end

    %w(cache_dir log_dir run_dir).each do |dir|
      directory node['nagios'][dir] do
        recursive true
        owner node['nagios']['user']
        group node['nagios']['group']
        mode '0755'
      end
    end

    directory ::File.join(node['nagios']['log_dir'], 'archives') do
      owner node['nagios']['user']
      group node['nagios']['group']
      mode '0755'
    end
  end

  def compile_command
    <<~EOH
      tar xzf nagios-#{node['nagios']['server']['version']}.tar.gz
      cd nagios-#{node['nagios']['server']['version']}
      ./configure --prefix=/usr \\
          --mandir=/usr/share/man \\
          --bindir=/usr/sbin \\
          --sbindir=#{node['nagios']['cgi-bin']} \\
          --datadir=#{node['nagios']['docroot']} \\
          --sysconfdir=#{node['nagios']['conf_dir']} \\
          --infodir=/usr/share/info \\
          --libexecdir=#{node['nagios']['plugin_dir']} \\
          --localstatedir=#{node['nagios']['state_dir']} \\
          --with-cgibindir=#{node['nagios']['cgi-bin']} \\
          --enable-event-broker \\
          --with-nagios-user=#{node['nagios']['user']} \\
          --with-nagios-group=#{node['nagios']['group']} \\
          --with-command-user=#{node['nagios']['user']} \\
          --with-command-group=#{node['nagios']['group']} \\
          --with-init-dir=/etc/init.d \\
          --with-lockfile=#{node['nagios']['run_dir']}/#{node['nagios']['server']['vname']}.pid \\
          --with-mail=/usr/bin/mail \\
          --with-perlcache \\
          --with-htmurl=/ \\
          --with-cgiurl=#{node['nagios']['cgi-path']}
      make all
      make install
      make install-cgis
      make install-init
      make install-config
      make install-commandmode
      #{node['nagios']['source']['add_build_commands'].join("\n")}
    EOH
  end
end
