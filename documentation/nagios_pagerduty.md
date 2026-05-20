# nagios_pagerduty

Installs the PagerDuty Nagios integration script, creates notification commands, and creates PagerDuty contacts.

## Actions

- `:create`

## Properties

- `key`: single PagerDuty integration key.
- `script_url`: URL for the PagerDuty Nagios script.
- `proxy_url`: optional proxy URL for script calls.
- `service_notification_options`: service notification options.
- `host_notification_options`: host notification options.
- `contact_data_bag`: data bag for additional PagerDuty contacts.

## Examples

```ruby
nagios_server 'default'

nagios_pagerduty 'default' do
  key 'pagerduty-service-key'
end
```
