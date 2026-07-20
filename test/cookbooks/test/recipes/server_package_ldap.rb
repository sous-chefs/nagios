# frozen_string_literal: true

nagios_server 'ldap' do
  config(
    'conf' => {
      'host_perfdata_command' => %w(command_a command_b),
      'query_socket' => nil,
      'use_syslog' => 0,
    },
    'ldap_url' => 'ldaps://ldap.example.org:636/ou=People,dc=example,dc=org?uid?sub?(objectClass=*)'
  )
  exclude_tag_host %w(foo)
  host_name_attribute 'custom_host_name_attribute'
  server_auth_method 'ldap'
  monitored_environments %w(_default)
  multi_environment_monitoring true
end

include_recipe 'test::objects'
