include NagiosCookbook::Helpers

property :users_databag, String, default: 'users'
property :users_databag_group, String, default: 'sysadmin'
property :use_encrypted_data_bags, [true, false], default: false
property :normalize_hostname, [true, false], default: false
property :load_default_config, [true, false], default: true
property :load_databag_config, [true, false], default: true
property :monitored_environments, Array
property :multi_environment_monitoring, [true, false], default: false
property :exclude_tag_host, String
property :host_template, String, default: 'server'
property :ssl_req

action :configure do
  # use the users_helper.rb library to build arrays of users and contacts
  nagios_users = NagiosUsers.new(node, new_resource)
  if nagios_users.users.empty?
    Chef::Log.fatal("Could not find users in the '#{new_resource.users_databag}' databag with the " \
    "'#{new_resource.users_databag_group}' group. Users must be defined to allow for logins to the UI. Make sure " \
    "the databag exists and, if you have set the 'users_databag_group', that users in that group exist.")
  end

  Nagios.instance.normalize_hostname = new_resource.normalize_hostname

  if new_resource.load_default_config
    # Find nodes to monitor.
    # Search in all environments if multi_environment_monitoring is enabled.
    Chef::Log.info('Beginning search for nodes.  This may take some time depending on your node count')
    nodes = search(:node, nagios_node_search(new_resource))

    if nodes.empty?
      Chef::Log.info('No nodes returned from search, using this node so hosts.cfg has data')
      nodes << node
    end

    # Pushing current node to prevent empty hosts.cfg
    Nagios.instance.push(node)

    # Pushing all nodes into the Nagios.instance model
    exclude_tag = nagios_array(new_resource.exclude_tag_host)
    nodes.each do |n|
      if n.respond_to?('tags')
        Nagios.instance.push(n) unless nagios_array(n.tags).any? { |tag| exclude_tag.include?(tag) }
      else
        Nagios.instance.push(n)
      end
    end

    # 24x7 timeperiod
    nagios_timeperiod '24x7' do
      nagios_alias '24 Hours A Day, 7 Days A Week'
      times(
        sunday: '00:00-24:00',
        monday: '00:00-24:00',
        tuesday: '00:00-24:00',
        wednesday: '00:00-24:00',
        thursday: '00:00-24:00',
        friday: '00:00-24:00',
        saturday: '00:00-24:00'
      )
    end

    # Host checks
    nagios_command 'check_host_alive' do
      command_line '$USER1$/check_ping -H $HOSTADDRESS$ -w 2000,80% -c 3000,100% -p 1'
    end

    # Service checks
    nagios_command 'check_nagios' do
      command_line '$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_nagios -t 20'
    end

    # nrpe remote host checks
    nagios_command 'check_nrpe_alive' do
      command_line '$USER1$/check_nrpe -H $HOSTADDRESS$ -t 20'
    end

    nagios_command 'check_nrpe' do
      command_line '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 20'
    end

    # host_notify_by_email command
    nagios_command 'host_notify_by_email' do
      command_line '/usr/bin/printf "%b" "$LONGDATETIME$\n\n$HOSTALIAS$ $NOTIFICATIONTYPE$ $HOSTSTATE$\n\n$HOSTOUTPUT$\n\nLogin: ssh://$HOSTNAME$" | ' + nagios_mail_command + ' -s "$NOTIFICATIONTYPE$ - $HOSTALIAS$ $HOSTSTATE$!" $CONTACTEMAIL$'
    end

    # service_notify_by_email command
    nagios_command 'service_notify_by_email' do
      command_line '/usr/bin/printf "%b" "$LONGDATETIME$ - $SERVICEDESC$ $SERVICESTATE$\n\n$HOSTALIAS$  $NOTIFICATIONTYPE$\n\n$SERVICEOUTPUT$\n\nLogin: ssh://$HOSTNAME$" | ' + nagios_mail_command + ' -s "** $NOTIFICATIONTYPE$ - $HOSTALIAS$ - $SERVICEDESC$ - $SERVICESTATE$" $CONTACTEMAIL$'
    end

    # host_notify_by_sms_email command
    nagios_command 'host_notify_by_sms_email' do
      command_line '/usr/bin/printf "%b" "$HOSTALIAS$ $NOTIFICATIONTYPE$ $HOSTSTATE$\n\n$HOSTOUTPUT$" | ' + nagios_mail_command + ' -s "$HOSTALIAS$ $HOSTSTATE$!" $CONTACTPAGER$'
    end

    # root contact
    nagios_contact 'root' do
      nagios_alias 'Root'
      service_notification_period '24x7'
      host_notification_period '24x7'
      service_notification_options 'w,u,c,r'
      host_notification_options 'd,r'
      service_notification_commands 'service_notify_by_email'
      host_notification_commands 'host_notify_by_email'
      email 'root@localhost'
    end

    # admin contact
    nagios_contact 'admin' do
      nagios_alias 'Admin'
      service_notification_period '24x7'
      host_notification_period '24x7'
      service_notification_options 'w,u,c,r'
      host_notification_options 'd,r'
      service_notification_commands 'service_notify_by_email'
      host_notification_commands 'host_notify_by_email'
    end

    nagios_contact 'default-contact' do
      service_notification_period '24x7'
      host_notification_period '24x7'
      service_notification_options 'w,u,c,r,f'
      host_notification_options 'd,u,r,f,s'
      service_notification_commands 'service_notify_by_email'
      host_notification_commands 'host_notify_by_email'
    end

    nagios_host 'default-host' do
      notifications_enabled 1
      event_handler_enabled 1
      flap_detection_enabled nagios_boolean(nagios_attr(:default_host)[:flap_detection])
      process_perf_data nagios_boolean(nagios_attr(:default_host)[:process_perf_data])
      retain_status_information 1
      retain_nonstatus_information 1
      notification_period '24x7'
      register 0
      action_url nagios_attr(:default_host)[:action_url]
    end

    nagios_host 'server' do
      use 'default-host'
      check_period nagios_attr(:default_host)[:check_period]
      check_interval nagios_interval(nagios_attr(:default_host)[:check_interval])
      retry_interval nagios_interval(nagios_attr(:default_host)[:retry_interval])
      max_check_attempts nagios_attr(:default_host)[:max_check_attempts]
      check_command nagios_attr(:default_host)[:check_command]
      notification_interval nagios_interval(nagios_attr(:default_host)[:notification_interval])
      notification_options nagios_attr(:default_host)[:notification_options]
      contact_groups nagios_attr(:default_contact_groups)
      register 0
    end

    # Defaut host template
    Nagios.instance.default_host = new_resource.host_template

    # Users
    # use the users_helper.rb library to build arrays of users and contacts
    nagios_users = NagiosUsers.new(node, new_resource)
    nagios_users.users.each do |item|
      o = Nagios::Contact.create(item['id'])
      o.import(item.to_hash)
      o.import(item['nagios'].to_hash) unless item['nagios'].nil?
      o.use = 'default-contact'
    end

    nagios_contactgroup 'admins' do
      nagios_alias 'Nagios Administrators'
      members nagios_users.return_user_contacts
    end

    nagios_contactgroup 'admins-sms' do
      nagios_alias 'Sysadmin SMS'
      members nagios_users.return_user_contacts
    end

    # Services
    nagios_service 'default-service' do
      active_checks_enabled 1
      passive_checks_enabled 1
      parallelize_check 1
      obsess_over_service 1
      check_freshness 0
      notifications_enabled 1
      event_handler_enabled 1
      flap_detection_enabled nagios_boolean(nagios_attr(:default_service)[:flap_detection])
      process_perf_data nagios_boolean(nagios_attr(:default_service)[:process_perf_data])
      retain_status_information 1
      retain_nonstatus_information 1
      is_volatile 0
      check_period '24x7'
      max_check_attempts nagios_attr(:default_service)[:max_check_attempts]
      check_interval nagios_interval(nagios_attr(:default_service)[:check_interval])
      retry_interval nagios_interval(nagios_attr(:default_service)[:retry_interval])
      contact_groups nagios_attr(:default_contact_groups)
      notification_options 'w,u,c,r'
      notification_interval nagios_interval(nagios_attr(:default_service)[:notification_interval])
      notification_period '24x7'
      register 0
      action_url nagios_attr(:default_service)[:action_url]
    end

    # Default service template
    Nagios.instance.default_service = 'default-service'

    # Define the log monitoring template (monitoring logs is very different)
    nagios_service 'default-logfile' do
      use 'default-service'
      check_period '24x7'
      max_check_attempts 1
      check_interval nagios_interval(nagios_attr(:default_service)[:check_interval])
      retry_interval nagios_interval(nagios_attr(:default_service)[:retry_interval])
      contact_groups nagios_attr(:default_contact_groups)
      notification_options 'w,u,c,r'
      notification_period '24x7'
      register 0
      is_volatile 1
    end

    nagios_service 'service-template' do
      max_check_attempts nagios_attr(:default_service)[:max_check_attempts]
      check_interval nagios_interval(nagios_attr(:default_service)[:check_interval])
      retry_interval nagios_interval(nagios_attr(:default_service)[:retry_interval])
      notification_interval nagios_interval(nagios_attr(:default_service)[:notification_interval])
      register 0
    end

    nagios_resource 'USER1' do
      value node['nagios']['plugin_dir']
    end
  end

  if new_resource.load_databag_config
    # do load_databag_config
  end

  directory "#{nagios_conf_dir}/dist" do
    owner 'nagios'
    group 'nagios'
  end

  directory nagios_state_dir do
    owner 'nagios'
    group 'nagios'
    mode '0751'
  end

  directory "#{nagios_state_dir}/rw" do
    owner 'nagios'
    group 'nagios'
    mode '2710'
  end

  cfg_files = "#{nagios_config_dir}/*_nagios*.cfg"

  execute 'archive-default-nagios-object-definitions' do
    command "mv #{cfg_files} #{nagios_conf_dir}/dist"
    not_if { Dir.glob(cfg_files).empty? }
  end

	nagios_conf 'nagios' do
		config_subdir false
		cookbook new_resource.template_cookbook node['nagios']['nagios_config']['template_cookbook']
		source node['nagios']['nagios_config']['template_file']
		variables(nagios_config: node['nagios']['conf'])
	end
end

action_class do
  include NagiosCookbook::Helpers
end
