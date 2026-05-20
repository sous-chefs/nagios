# frozen_string_literal: true

provides :nagios_configure
unified_mode true

action :create do
  nagios_install 'nagios'

  nagios_users = NagiosUsers.new(node)
  if nagios_users.users.empty?
    Chef::Log.fatal('Could not find users in the ' \
      "\"#{node['nagios']['users_databag']}\"" \
      "databag with the \"#{node['nagios']['users_databag_group']}\"" \
      ' group. Users must be defined to allow for logins to the UI.')
  end

  if node['nagios']['server_auth_method'] == 'htauth'
    directory node['nagios']['conf_dir']

    template "#{node['nagios']['conf_dir']}/htpasswd.users" do
      cookbook node['nagios']['htauth']['template_cookbook']
      source node['nagios']['htauth']['template_file']
      owner node['nagios']['user']
      group node['nagios']['web_group']
      mode '0640'
      variables(nagios_users: nagios_users.users)
    end
  end

  Nagios.instance.normalize_hostname = node['nagios']['server']['normalize_hostname']
  Nagios.instance.host_name_attribute = node['nagios']['host_name_attribute']

  nagios_default_config 'default' if node['nagios']['server']['load_default_config']
  nagios_data_bag_config 'default' if node['nagios']['server']['load_databag_config']

  directory "#{node['nagios']['conf_dir']}/dist" do
    owner node['nagios']['user']
    group node['nagios']['group']
    mode '0755'
  end

  directory node['nagios']['state_dir'] do
    owner node['nagios']['user']
    group node['nagios']['group']
    mode '0751'
  end unless platform_family?('rhel', 'fedora')

  directory "#{node['nagios']['state_dir']}/rw" do
    owner node['nagios']['user']
    group node['nagios']['web_group']
    mode '2710'
  end

  execute 'archive-default-nagios-object-definitions' do
    command "mv #{node['nagios']['config_dir']}/*_#{node['nagios']['server']['name']}*.cfg #{node['nagios']['conf_dir']}/dist"
    not_if { Dir.glob("#{node['nagios']['config_dir']}/*_#{node['nagios']['server']['name']}*.cfg").empty? }
  end

  directory "#{node['nagios']['conf_dir']}/certificates" do
    owner node['nagios']['web_user']
    group node['nagios']['web_group']
    mode '0700'
  end

  execute 'Create SSL Certificates' do
    cwd "#{node['nagios']['conf_dir']}/certificates"
    command ssl_command
    not_if { ::File.exist?(node['nagios']['ssl_cert_file']) }
  end

  nagios_conf node['nagios']['server']['name'] do
    config_subdir false
    cookbook node['nagios']['nagios_config']['template_cookbook']
    source node['nagios']['nagios_config']['template_file']
    variables(nagios_config: node['nagios']['conf'])
  end

  nagios_conf 'cgi' do
    config_subdir false
    cookbook node['nagios']['cgi']['template_cookbook']
    source node['nagios']['cgi']['template_file']
    variables(nagios_service_name: nagios_service_name)
  end

  if platform_family?('rhel', 'fedora')
    template "#{node['nagios']['resource_dir']}/resource.cfg" do
      cookbook node['nagios']['resources']['template_cookbook']
      source node['nagios']['resources']['template_file']
      owner node['nagios']['user']
      group node['nagios']['group']
      mode '0600'
    end

    directory node['nagios']['resource_dir'] do
      owner 'root'
      group node['nagios']['group']
      mode '0755'
    end
  end

  %w(timeperiods contacts commands hosts hostgroups templates services servicegroups servicedependencies).each do |conf|
    nagios_conf conf
  end

  with_run_context(:root) do
    service 'nagios' do
      service_name nagios_service_name
      if ::File.exist?("#{nagios_config_dir}/services.cfg")
        action [:enable, :start]
      else
        action :enable
      end
    end
  end

  zap_directory nagios_distro_config_dir do
    pattern '*.cfg'
  end
end

action_class do
  include NagiosCookbook::Helpers
  require_relative '../libraries/users_helper'

  def nagios_service_name
    if platform_family?('debian') && node['nagios']['server']['install_method'] == 'source'
      node['nagios']['server']['name']
    else
      node['nagios']['server']['service_name']
    end
  end

  def ssl_command
    <<~EOH
      umask 077
      openssl genrsa 2048 > nagios-server.key
      openssl req -subj #{node['nagios']['ssl_req']} -new -x509 -nodes -sha1 -days 3650 -key nagios-server.key > nagios-server.crt
      cat nagios-server.key nagios-server.crt > nagios-server.pem
    EOH
  end
end
