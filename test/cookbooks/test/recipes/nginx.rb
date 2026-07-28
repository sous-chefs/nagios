# frozen_string_literal: true

nagios_server 'nginx' do
  config(
    'conf' => {
      'host_perfdata_command' => %w(command_a command_b),
      'query_socket' => nil,
      'use_syslog' => 0,
    }
  )
  exclude_tag_host %w(foo)
  host_name_attribute 'custom_host_name_attribute'
  monitored_environments %w(_default)
  multi_environment_monitoring true
  web_server 'nginx'
  stop_apache true
end

include_recipe 'test::objects'
