# frozen_string_literal: true

nagios_server 'pagerduty' do
  config(
    'conf' => {
      'host_perfdata_command' => %w(command_a command_b),
      'query_socket' => nil,
      'use_syslog' => 0,
    }
  )
  exclude_tag_host %w(foo)
  host_name_attribute 'custom_host_name_attribute'
  install_method 'package'
  monitored_environments %w(_default)
  multi_environment_monitoring true
end

nagios_pagerduty 'pagerduty' do
  key 'your_key_here_3eC2'
end

include_recipe 'test::objects'
