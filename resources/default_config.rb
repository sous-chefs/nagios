# frozen_string_literal: true

provides :nagios_default_config
unified_mode true

use '_partial/_settings'

property :users, [Array, nil], default: nil

action :create do
  Chef::Log.info('Beginning search for nodes. This may take some time depending on node count')

  multi_env = settings['monitored_environments']
  multi_env_search = multi_env.empty? ? '' : " AND (chef_environment:#{multi_env.join(' OR chef_environment:')})"

  nodes = if settings['multi_environment_monitoring']
            search(:node, "name:*#{multi_env_search}")
          else
            search(:node, "name:* AND chef_environment:#{node.chef_environment}")
          end

  if nodes.empty?
    Chef::Log.info('No nodes returned from search, using this node so hosts.cfg has data')
    nodes << node
  end

  Nagios.instance.push(node)

  exclude_tag = nagios_array(settings['exclude_tag_host'])
  nodes.each do |monitored_node|
    if monitored_node.respond_to?('tags')
      Nagios.instance.push(monitored_node) unless nagios_array(monitored_node.tags).any? { |tag| exclude_tag.include?(tag) }
    else
      Nagios.instance.push(monitored_node)
    end
  end

  nagios_timeperiod '24x7' do
    options 'alias' => '24 Hours A Day, 7 Days A Week',
            'times' => {
              'sunday' => '00:00-24:00',
              'monday' => '00:00-24:00',
              'tuesday' => '00:00-24:00',
              'wednesday' => '00:00-24:00',
              'thursday' => '00:00-24:00',
              'friday' => '00:00-24:00',
              'saturday' => '00:00-24:00',
            }
  end

  nagios_command 'check_host_alive' do
    options 'command_line' => '$USER1$/check_ping -H $HOSTADDRESS$ -w 2000,80% -c 3000,100% -p 1'
  end

  nagios_command 'check_nagios' do
    options 'command_line' => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_nagios -t 20'
  end

  nagios_command 'check_nrpe_alive' do
    options 'command_line' => '$USER1$/check_nrpe -H $HOSTADDRESS$ -t 20'
  end

  nagios_command 'check_nrpe' do
    options 'command_line' => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 20'
  end

  nagios_command 'host_notify_by_email' do
    options 'command_line' => '/usr/bin/printf "%b" "$LONGDATETIME$\n\n$HOSTALIAS$ $NOTIFICATIONTYPE$ $HOSTSTATE$\n\n$HOSTOUTPUT$\n\nLogin: ssh://$HOSTNAME$" | ' + settings['server']['mail_command'] + ' -s "$NOTIFICATIONTYPE$ - $HOSTALIAS$ $HOSTSTATE$!" $CONTACTEMAIL$'
  end

  nagios_command 'service_notify_by_email' do
    options 'command_line' => '/usr/bin/printf "%b" "$LONGDATETIME$ - $SERVICEDESC$ $SERVICESTATE$\n\n$HOSTALIAS$  $NOTIFICATIONTYPE$\n\n$SERVICEOUTPUT$\n\nLogin: ssh://$HOSTNAME$" | ' + settings['server']['mail_command'] + ' -s "** $NOTIFICATIONTYPE$ - $HOSTALIAS$ - $SERVICEDESC$ - $SERVICESTATE$" $CONTACTEMAIL$'
  end

  nagios_command 'host_notify_by_sms_email' do
    options 'command_line' => '/usr/bin/printf "%b" "$HOSTALIAS$ $NOTIFICATIONTYPE$ $HOSTSTATE$\n\n$HOSTOUTPUT$" | ' + settings['server']['mail_command'] + ' -s "$HOSTALIAS$ $HOSTSTATE$!" $CONTACTPAGER$'
  end

  nagios_command 'service_notify_by_sms_email' do
    options 'command_line' => '/usr/bin/printf "%b" "$SERVICEDESC$ $NOTIFICATIONTYPE$ $SERVICESTATE$\n\n$SERVICEOUTPUT$" | ' + settings['server']['mail_command'] + ' -s "$HOSTALIAS$ $SERVICEDESC$ $SERVICESTATE$!" $CONTACTPAGER$'
  end

  create_default_contacts
  create_default_hosts
  create_default_services

  nagios_resource 'USER1' do
    options 'value' => settings['plugin_dir']
  end
end

action_class do
  include NagiosCookbook::Helpers
  require_relative '../libraries/users_helper'

  def settings
    new_resource.settings
  end

  def create_default_contacts
    nagios_contact 'root' do
      options 'alias' => 'Root',
              'service_notification_period' => '24x7',
              'host_notification_period' => '24x7',
              'service_notification_options' => 'w,u,c,r',
              'host_notification_options' => 'd,r',
              'service_notification_commands' => 'service_notify_by_email',
              'host_notification_commands' => 'host_notify_by_email',
              'email' => 'root@localhost'
    end

    nagios_contact 'admin' do
      options 'alias' => 'Admin',
              'service_notification_period' => '24x7',
              'host_notification_period' => '24x7',
              'service_notification_options' => 'w,u,c,r',
              'host_notification_options' => 'd,r',
              'service_notification_commands' => 'service_notify_by_email',
              'host_notification_commands' => 'host_notify_by_email'
    end

    nagios_contact 'default-contact' do
      options 'name' => 'default-contact',
              'service_notification_period' => '24x7',
              'host_notification_period' => '24x7',
              'service_notification_options' => 'w,u,c,r,f',
              'host_notification_options' => 'd,u,r,f,s',
              'service_notification_commands' => 'service_notify_by_email',
              'host_notification_commands' => 'host_notify_by_email'
    end

    nagios_users = NagiosUsers.new(node, settings: settings, users: new_resource.users)
    nagios_users.users.each do |item|
      contact = Nagios::Contact.create(item['id'])
      contact.import(item.to_hash)
      contact.import(item['nagios'].to_hash) unless item['nagios'].nil?
      contact.use = 'default-contact'
    end

    nagios_contactgroup 'admins' do
      options 'alias' => 'Nagios Administrators',
              'members' => nagios_users.return_user_contacts
    end

    nagios_contactgroup 'admins-sms' do
      options 'alias' => 'Sysadmin SMS',
              'members' => nagios_users.return_user_contacts
    end
  end

  def create_default_hosts
    nagios_host 'default-host' do
      options 'name' => 'default-host',
              'notifications_enabled' => 1,
              'event_handler_enabled' => 1,
              'flap_detection_enabled' => nagios_boolean(settings['default_host']['flap_detection']),
              'process_perf_data' => nagios_boolean(settings['default_host']['process_perf_data']),
              'retain_status_information' => 1,
              'retain_nonstatus_information' => 1,
              'notification_period' => '24x7',
              'register' => 0,
              'action_url' => settings['default_host']['action_url']
    end

    nagios_host 'server' do
      options 'name' => 'server',
              'use' => 'default-host',
              'check_period' => settings['default_host']['check_period'],
              'check_interval' => nagios_interval(settings['default_host']['check_interval'], interval_length),
              'retry_interval' => nagios_interval(settings['default_host']['retry_interval'], interval_length),
              'max_check_attempts' => settings['default_host']['max_check_attempts'],
              'check_command' => settings['default_host']['check_command'],
              'notification_interval' => nagios_interval(settings['default_host']['notification_interval'], interval_length),
              'notification_options' => settings['default_host']['notification_options'],
              'contact_groups' => settings['default_contact_groups'],
              'register' => 0
    end

    Nagios.instance.default_host = settings['host_template']
  end

  def create_default_services
    nagios_service 'default-service' do
      options 'name' => 'default-service',
              'active_checks_enabled' => 1,
              'passive_checks_enabled' => 1,
              'parallelize_check' => 1,
              'obsess_over_service' => 1,
              'check_freshness' => 0,
              'notifications_enabled' => 1,
              'event_handler_enabled' => 1,
              'flap_detection_enabled' => nagios_boolean(settings['default_service']['flap_detection']),
              'process_perf_data' => nagios_boolean(settings['default_service']['process_perf_data']),
              'retain_status_information' => 1,
              'retain_nonstatus_information' => 1,
              'is_volatile' => 0,
              'check_period' => '24x7',
              'max_check_attempts' => settings['default_service']['max_check_attempts'],
              'check_interval' => nagios_interval(settings['default_service']['check_interval'], interval_length),
              'retry_interval' => nagios_interval(settings['default_service']['retry_interval'], interval_length),
              'contact_groups' => settings['default_contact_groups'],
              'notification_options' => 'w,u,c,r',
              'notification_interval' => nagios_interval(settings['default_service']['notification_interval'], interval_length),
              'notification_period' => '24x7',
              'register' => 0,
              'action_url' => settings['default_service']['action_url']
    end

    Nagios.instance.default_service = 'default-service'

    nagios_service 'default-logfile' do
      options 'name' => 'default-logfile',
              'use' => 'default-service',
              'check_period' => '24x7',
              'max_check_attempts' => 1,
              'check_interval' => nagios_interval(settings['default_service']['check_interval'], interval_length),
              'retry_interval' => nagios_interval(settings['default_service']['retry_interval'], interval_length),
              'contact_groups' => settings['default_contact_groups'],
              'notification_options' => 'w,u,c,r',
              'notification_period' => '24x7',
              'register' => 0,
              'is_volatile' => 1
    end

    nagios_service 'service-template' do
      options 'name' => 'service-template',
              'max_check_attempts' => settings['default_service']['max_check_attempts'],
              'check_interval' => nagios_interval(settings['default_service']['check_interval'], interval_length),
              'retry_interval' => nagios_interval(settings['default_service']['retry_interval'], interval_length),
              'notification_interval' => nagios_interval(settings['default_service']['notification_interval'], interval_length),
              'register' => 0
    end
  end

  def interval_length
    settings['conf']['interval_length']
  end
end
