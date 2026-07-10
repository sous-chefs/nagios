# nagios_server

Installs and configures a Nagios Core server.

## Actions

- `:create`

## Properties

### Installation

- `install_method`: `package` or `source`. Defaults by platform.
- `package_names`: package list override.
- `install_yum_epel`: install EPEL on RHEL-family platforms.
- `source_version`, `source_checksum`, `source_url`: source release settings.
- `source_patch_url`, `source_patches`: optional source patch settings.
- `source_dependencies`, `source_add_build_commands`: source build overrides.

### Web Front End

- `web_server`: `apache`, `nginx`, or `none`.
- `enable_ssl`, `http_port`, `ssl_cert_file`, `ssl_cert_key`, `ssl_cert_chain_file`, `ssl_req`, `ssl_protocols`, `ssl_ciphers`: SSL and listener settings.
- `server_name`, `server_alias`, `url`, `apache_mpm`: virtual host settings.
- `nginx_dispatch_type`, `nginx_dispatch_packages`, `nginx_dispatch_services`, `nginx_dispatch_cgi_url`, `stop_apache`: NGINX settings.

### Paths and Users

- `nagios_name`, `server_vname`, `service_name`: Nagios naming overrides.
- `nagios_user`, `nagios_group`, `web_user`, `web_group`: service users.
- `home`, `conf_dir`, `resource_dir`, `config_dir`, `log_dir`, `cache_dir`, `state_dir`, `run_dir`, `docroot`, `cgi_bin`, `cgi_path`, `plugin_dir`: path overrides.

### Discovery and Configuration

- `config`, `cgi_config`, `default_host`, `default_service`, `templates`, `brokers`: Nagios configuration hashes.
- `multi_environment_monitoring`, `monitored_environments`, `monitoring_interface`, `exclude_tag_host`: Chef search settings.
- `host_name_attribute`, `regexp_matching`, `host_template`, `normalize_hostname`: object rendering settings.
- `load_default_config`, `load_databag_config`, `use_encrypted_data_bags`: generated and data bag configuration toggles.

### Authentication and Contacts

- `server_auth_method`, `server_auth_require`, `default_contact_groups`, `default_user_name`: UI authentication.
- `sysadmin_email`, `sysadmin_sms_email`, `check_external_commands`, `allowed_ips`: contact and access settings.
- `users`: explicit admin users. When set, this overrides the users data bag search.
- `users_databag`, `users_databag_group`: admin user search settings.
- `services_databag`, `servicegroups_databag`, `templates_databag`, `hosttemplates_databag`, `eventhandlers_databag`, `unmanagedhosts_databag`, `serviceescalations_databag`, `hostgroups_databag`, `hostescalations_databag`, `contacts_databag`, `contactgroups_databag`, `servicedependencies_databag`, `timeperiods_databag`: data bag names.

### Templates and PagerDuty

- `htauth_template_cookbook`, `htauth_template_file`: htpasswd template.
- `nagios_config_template_cookbook`, `nagios_config_template_file`: main Nagios config template.
- `resource_template_cookbook`, `resource_template_file`: resource config template.
- `cgi_template_cookbook`, `cgi_template_file`: CGI config template.
- `mail_command`, `pagerduty_key`, `pagerduty_script_url`, `pagerduty_service_notification_options`, `pagerduty_host_notification_options`, `pagerduty_proxy_url`: notification helpers.

## Examples

```ruby
nagios_server 'default'
```

```ruby
nagios_server 'default' do
  web_server 'nginx'
  server_auth_method 'htauth'
  config(
    'enable_notifications' => 1
  )
end
```

```ruby
nagios_server 'default' do
  users [
    {
      'id' => 'alice',
      'htpasswd' => '$apr1$...',
      'nagios' => {
        'email' => 'alice@example.com',
        'pager' => 'alice-sms@example.com',
      },
    },
  ]
end
```
