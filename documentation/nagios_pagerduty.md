# nagios_pagerduty

Installs the PagerDuty Nagios integration script, creates notification commands, and creates PagerDuty contacts.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Installs and configures the integration (default). |
| `:delete` | Removes the script, CGI, cron entry, and generated objects. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | String, nil | `nil` | Single PagerDuty integration key. |
| `script_url` | String | PagerDuty upstream URL | Integration script URL. |
| `proxy_url` | String, nil | `nil` | Optional proxy URL. |
| `service_notification_options` | String | `'w,u,c,r'` | Service notification states. |
| `host_notification_options` | String | `'d,r'` | Host notification states. |
| `contact_data_bag` | String | `'nagios_pagerduty'` | Additional contact data bag. |
| `plugin_dir` | String | platform default | Nagios plugin directory. |
| `cgi_bin` | String | platform default | Nagios CGI directory. |
| `nagios_user` | String | `'nagios'` | Script and cron user. |
| `nagios_group` | String | `'nagios'` | CGI file group. |
| `command_file` | String | platform default | Nagios external command file. |

## Examples

```ruby
nagios_server 'default'

nagios_pagerduty 'default' do
  key 'pagerduty-service-key'
end
```
