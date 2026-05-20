# Migration

This release removes the legacy public recipe and attribute API. Use custom resources from wrapper cookbooks instead.

## Recipe Mapping

| Previous API | Replacement |
| --- | --- |
| `recipe[nagios::default]` | `nagios_server 'default'` |
| `recipe[nagios::server]` | `nagios_server 'default'` |
| `recipe[nagios::server_package]` | `nagios_server 'default'` with `install_method 'package'` |
| `recipe[nagios::server_source]` | `nagios_server 'default'` with `install_method 'source'` |
| `recipe[nagios::apache]` | `nagios_server 'default'` with `web_server 'apache'` |
| `recipe[nagios::nginx]` | `nagios_server 'default'` with `web_server 'nginx'` |
| `recipe[nagios::pagerduty]` | `nagios_pagerduty 'default'` |

## Attribute Mapping

Move former `node['nagios']` attribute overrides into `nagios_server` properties.

```ruby
# Before
default['nagios']['server_auth_method'] = 'ldap'
default['nagios']['server']['install_method'] = 'source'
default['nagios']['conf']['enable_notifications'] = 1

# After
nagios_server 'default' do
  server_auth_method 'ldap'
  install_method 'source'
  config(
    'enable_notifications' => 1
  )
end
```

Nested configuration hashes remain available through resource properties such as `config`, `cgi_config`, `default_host`, `default_service`, `templates`, and `brokers`.

## Wrapper Cookbook Example

```ruby
nagios_server 'default' do
  server_auth_method 'htauth'
  users_databag 'users'
  users_databag_group 'sysadmin'
  load_default_config true
  load_databag_config true
end

nagios_host 'web01' do
  options(
    'address' => '192.0.2.10',
    'use' => 'server'
  )
end
```

Declare `nagios_pagerduty` after `nagios_server` because it uses the server paths calculated by `nagios_server`.
