# nagios_serviceescalation

Declares a Nagios service escalation object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the escalation (default). |
| `:delete` | Removes the escalation. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios service escalation directives. |

## Examples

```ruby
nagios_serviceescalation 'critical-http' do
  options(
    'hostgroup_name' => 'web-servers',
    'service_description' => 'HTTP',
    'first_notification' => 3,
    'last_notification' => 0,
    'contact_groups' => 'operations'
  )
end
```
