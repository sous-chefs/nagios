# frozen_string_literal: true

provides :nagios_pagerduty
unified_mode true

property :key, [String, nil]
property :script_url, String, default: 'https://raw.github.com/PagerDuty/pagerduty-nagios-pl/master/pagerduty_nagios.pl'
property :proxy_url, [String, nil]
property :service_notification_options, String, default: 'w,u,c,r'
property :host_notification_options, String, default: 'd,r'
property :contact_data_bag, String, default: 'nagios_pagerduty'

action :create do
  package nagios_pagerduty_packages

  remote_file "#{node['nagios']['plugin_dir']}/notify_pagerduty.pl" do
    owner 'root'
    group 'root'
    mode '0755'
    source new_resource.script_url
    action :create_if_missing
  end

  template "#{node['nagios']['cgi-bin']}/pagerduty.cgi" do
    cookbook 'nagios'
    source 'pagerduty.cgi.erb'
    owner node['nagios']['user']
    group node['nagios']['group']
    mode '0755'
    variables(command_file: node['nagios']['conf']['command_file'])
  end

  nagios_command 'notify-service-by-pagerduty' do
    options 'command_line' => pagerduty_command('service')
  end

  nagios_command 'notify-host-by-pagerduty' do
    options 'command_line' => pagerduty_command('host')
  end

  unless new_resource.key.nil? || new_resource.key.empty?
    nagios_contact 'pagerduty' do
      options 'alias' => 'PagerDuty Pseudo-Contact',
              'service_notification_period' => '24x7',
              'host_notification_period' => '24x7',
              'service_notification_options' => new_resource.service_notification_options,
              'host_notification_options' => new_resource.host_notification_options,
              'service_notification_commands' => 'notify-service-by-pagerduty',
              'host_notification_commands' => 'notify-host-by-pagerduty',
              'pager' => new_resource.key
    end
  end

  NagiosDataBags.new.get(new_resource.contact_data_bag).each do |contact|
    name = contact['contact'] || contact['id']

    nagios_contact name do
      options 'alias' => "PagerDuty Pseudo-Contact #{name}",
              'service_notification_period' => contact['service_notification_period'] || '24x7',
              'host_notification_period' => contact['host_notification_period'] || '24x7',
              'service_notification_options' => contact['service_notification_options'] || 'w,u,c,r',
              'host_notification_options' => contact['host_notification_options'] || 'd,r',
              'service_notification_commands' => 'notify-service-by-pagerduty',
              'host_notification_commands' => 'notify-host-by-pagerduty',
              'pager' => contact['key'] || contact['pagerduty_key'],
              'contactgroups' => contact['contactgroups']
    end
  end

  cron 'Flush Pagerduty' do
    user node['nagios']['user']
    mailto 'root@localhost'
    command "#{::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl')} flush"
  end
end

action_class do
  include NagiosCookbook::Helpers
  require_relative '../libraries/data_bag_helper'

  def pagerduty_command(object_type)
    command = ::File.join(node['nagios']['plugin_dir'], 'notify_pagerduty.pl') +
              " enqueue -f pd_nagios_object=#{object_type} -f pd_description=\"$HOSTNAME$ : $SERVICEDESC$\""
    new_resource.proxy_url.nil? ? command : "#{command} --proxy #{new_resource.proxy_url}"
  end
end
