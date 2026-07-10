# nagios cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/nagios.svg)](https://supermarket.chef.io/cookbooks/nagios)
[![CI State](https://github.com/sous-chefs/nagios/workflows/ci/badge.svg)](https://github.com/sous-chefs/nagios/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Installs and configures a Nagios Core server using Chef Infra custom resources. Chef nodes can be discovered with search, and Nagios object files can be rendered from resources or data bags.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. To learn more, visit [sous-chefs.org](https://sous-chefs.org/) or join the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### Chef

Chef Infra Client 15.3 or later is required.

This cookbook relies on Chef search for automatic user and node discovery, so those features require Chef Infra Server. Chef Solo users can still use the object resources directly, but should not enable search-backed default or data bag configuration.

### Platforms

- AlmaLinux 8+
- CentOS Stream 9+
- Debian 12+
- Fedora
- Oracle Linux 8+
- Red Hat Enterprise Linux 8+
- Rocky Linux 8+
- Ubuntu 22.04+

See [LIMITATIONS.md](LIMITATIONS.md) for platform and package-source notes.

### Cookbooks

- apache2
- build-essential
- nginx
- php
- yum-epel
- zap

## Usage

Add `nagios_server` to a wrapper cookbook recipe:

```ruby
nagios_server 'default' do
  server_auth_method 'htauth'
end
```

The server resource installs Nagios, configures Apache by default, searches for admin users in the `users` data bag with the `sysadmin` group, renders Nagios configuration files, and enables the Nagios service.

To use NGINX instead of Apache:

```ruby
nagios_server 'default' do
  web_server 'nginx'
  stop_apache true
end
```

To install from source:

```ruby
nagios_server 'default' do
  install_method 'source'
  source_version '4.4.6'
  source_checksum 'ab0d5a52caf01e6f4dcd84252c4eb5df5a24f90bb7f951f03875eef54f5ab0f4'
end
```

To use a custom Nagios main configuration template:

```ruby
nagios_server 'default' do
  nagios_config_template_cookbook 'my_monitoring'
  nagios_config_template_file 'nagios.cfg.erb'
end
```

To create Nagios objects directly:

```ruby
nagios_host 'web01' do
  options(
    'address' => '192.0.2.10',
    'use' => 'server'
  )
end

nagios_service 'http-web01' do
  options(
    'host_name' => 'web01',
    'service_description' => 'HTTP',
    'check_command' => 'check_http'
  )
end
```

The previous `nagios::default`, `nagios::server_package`, `nagios::server_source`, `nagios::apache`, `nagios::nginx`, and `nagios::pagerduty` recipes have been removed. See [migration.md](migration.md) for the recipe-to-resource mapping.

## Resources

- [nagios_server](documentation/nagios_server.md)
- [nagios_install](documentation/nagios_install.md)
- [nagios_configure](documentation/nagios_configure.md)
- [nagios_apache](documentation/nagios_apache.md)
- [nagios_nginx](documentation/nagios_nginx.md)
- [nagios_default_config](documentation/nagios_default_config.md)
- [nagios_data_bag_config](documentation/nagios_data_bag_config.md)
- [nagios_pagerduty](documentation/nagios_pagerduty.md)
- [nagios_conf](documentation/nagios_conf.md)
- [Nagios object resources](documentation/nagios_objects.md)

## Data Bags

The server resource searches the `users` data bag for users in the configured admin group. A minimal item looks like:

```json
{
  "id": "alice",
  "groups": ["sysadmin"],
  "nagios": {
    "email": "alice@example.com",
    "pager": "alice-sms@example.com"
  }
}
```

To bypass the users data bag search, pass the users directly to `nagios_server`:

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

Additional object data bags can be loaded by `nagios_data_bag_config` or by enabling `load_databag_config` on `nagios_server`. The default bag names are exposed as `nagios_server` properties.

PagerDuty contacts can be declared with `nagios_pagerduty`:

```ruby
nagios_pagerduty 'default' do
  key 'pagerduty-service-key'
end
```

Multiple PagerDuty contacts can also be loaded from the `nagios_pagerduty` data bag.

## Monitoring Role

The system running the Nagios server should have a role matching the value used by NRPE clients, typically `monitoring`.

```ruby
name 'monitoring'
description 'Monitoring server'
run_list 'recipe[my_monitoring::nagios]'
```

Apply the nrpe cookbook to monitored nodes so NRPE checks are available to Nagios.

## Notifications

Set the `config` property to enable Nagios notifications:

```ruby
nagios_server 'default' do
  config(
    'enable_notifications' => 1
  )
end
```

Email notifications require a local mail program and MTA so `/usr/bin/mail` or `/bin/mail` is available.

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
