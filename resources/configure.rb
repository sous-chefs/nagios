# frozen_string_literal: true

provides :nagios_configure
unified_mode true

use '_partial/_settings'

property :users, [Array, nil], default: nil

action :create do
  nagios_install 'nagios' do
    settings new_resource.settings
  end

  nagios_users = NagiosUsers.new(node, settings: settings, users: new_resource.users)
  if nagios_users.users.empty?
    Chef::Log.fatal('Could not find users in the ' \
      "\"#{settings['users_databag']}\"" \
      "databag with the \"#{settings['users_databag_group']}\"" \
      ' group. Users must be defined to allow for logins to the UI.')
  end

  if settings['server_auth_method'] == 'htauth'
    directory settings['conf_dir']

    template "#{settings['conf_dir']}/htpasswd.users" do
      cookbook settings['htauth']['template_cookbook']
      source settings['htauth']['template_file']
      owner settings['user']
      group settings['web_group']
      mode '0640'
      variables(nagios_users: nagios_users.users)
    end
  end

  Nagios.instance.normalize_hostname = settings['server']['normalize_hostname']
  Nagios.instance.host_name_attribute = settings['host_name_attribute']

  if settings['server']['load_default_config']
    nagios_default_config 'default' do
      settings new_resource.settings
      users new_resource.users
    end
  end
  if settings['server']['load_databag_config']
    nagios_data_bag_config 'default' do
      settings new_resource.settings
    end
  end

  directory "#{settings['conf_dir']}/dist" do
    owner settings['user']
    group settings['group']
    mode '0755'
  end

  directory settings['state_dir'] do
    owner settings['user']
    group settings['group']
    mode '0751'
  end unless platform_family?('rhel', 'fedora')

  directory "#{settings['state_dir']}/rw" do
    owner settings['user']
    group settings['web_group']
    mode '2710'
  end

  execute 'archive-default-nagios-object-definitions' do
    command "mv #{settings['config_dir']}/*_#{settings['server']['name']}*.cfg #{settings['conf_dir']}/dist"
    not_if { Dir.glob("#{settings['config_dir']}/*_#{settings['server']['name']}*.cfg").empty? }
  end

  directory "#{settings['conf_dir']}/certificates" do
    owner settings['web_user']
    group settings['web_group']
    mode '0700'
  end

  execute 'Create SSL Certificates' do
    cwd "#{settings['conf_dir']}/certificates"
    command ssl_command
    not_if { ::File.exist?(settings['ssl_cert_file']) }
  end

  nagios_conf settings['server']['name'] do
    config_subdir false
    conf_dir settings['conf_dir']
    config_dir settings['config_dir']
    cookbook settings['nagios_config']['template_cookbook']
    source settings['nagios_config']['template_file']
    owner settings['user']
    group settings['group']
    service_name 'nagios'
    variables(nagios_config: settings['conf'])
  end

  nagios_conf 'cgi' do
    config_subdir false
    conf_dir settings['conf_dir']
    config_dir settings['config_dir']
    cookbook settings['cgi']['template_cookbook']
    source settings['cgi']['template_file']
    owner settings['user']
    group settings['group']
    service_name 'nagios'
    variables(nagios_service_name: nagios_service_name, settings: settings)
  end

  if platform_family?('rhel', 'fedora')
    template "#{settings['resource_dir']}/resource.cfg" do
      cookbook settings['resources']['template_cookbook']
      source settings['resources']['template_file']
      owner settings['user']
      group settings['group']
      mode '0600'
    end

    directory settings['resource_dir'] do
      owner 'root'
      group settings['group']
      mode '0755'
    end
  end

  %w(timeperiods contacts commands hosts hostgroups templates services servicegroups servicedependencies).each do |conf|
    nagios_conf conf do
      conf_dir settings['conf_dir']
      config_dir settings['config_dir']
      owner settings['user']
      group settings['group']
      service_name 'nagios'
      variables(settings: settings)
    end
  end

  platform_service_name = nagios_service_name

  with_run_context(:root) do
    service 'nagios' do
      service_name platform_service_name
      if ::File.exist?("#{settings['config_dir']}/services.cfg")
        action [:enable, :start]
      else
        action :enable
      end
    end
  end

  zap_directory distro_config_dir do
    pattern '*.cfg'
  end
end

action :delete do
  service nagios_service_name do
    action [:stop, :disable]
    ignore_failure true
  end

  [
    "#{settings['conf_dir']}/htpasswd.users",
    "#{settings['conf_dir']}/#{settings['server']['name']}.cfg",
    "#{settings['conf_dir']}/cgi.cfg",
    "#{settings['resource_dir']}/resource.cfg",
  ].uniq.each do |path|
    file path do
      action :delete
    end
  end

  %w(timeperiods contacts commands hosts hostgroups templates services servicegroups servicedependencies).each do |conf|
    nagios_conf conf do
      conf_dir settings['conf_dir']
      config_dir settings['config_dir']
      owner settings['user']
      group settings['group']
      service_name 'nagios'
      action :delete
    end
  end
end

action_class do
  include NagiosCookbook::Helpers
  require_relative '../libraries/users_helper'

  def settings
    new_resource.settings
  end

  def nagios_service_name
    if platform_family?('debian') && settings['server']['install_method'] == 'source'
      settings['server']['name']
    else
      settings['server']['service_name']
    end
  end

  def distro_config_dir
    platform_family?('rhel') ? "#{settings['conf_dir']}/objects" : "#{settings['conf_dir']}/dist"
  end

  def ssl_command
    <<~EOH
      umask 077
      openssl genrsa 2048 > nagios-server.key
      openssl req -subj #{settings['ssl_req']} -new -x509 -nodes -sha256 -days 3650 -key nagios-server.key > nagios-server.crt
      cat nagios-server.key nagios-server.crt > nagios-server.pem
    EOH
  end
end
