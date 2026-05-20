# frozen_string_literal: true

nagios_server 'ldap' do
  server_auth_method 'ldap'
  ldap_config = {
    'ldap_url' => 'ldaps://ldap.example.org:636/ou=People,dc=example,dc=org?uid?sub?(objectClass=*)',
  }
  config ldap_config
end

include_recipe 'test::objects'
