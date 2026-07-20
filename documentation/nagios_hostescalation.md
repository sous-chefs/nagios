# nagios_hostescalation

Declares a Nagios host escalation object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the escalation (default). |
| `:delete` | Removes the escalation. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios host escalation directives. |

## Examples

```ruby
nagios_hostescalation 'database-hosts' do
  options(
    'hostgroup_name' => 'databases',
    'first_notification' => 3,
    'last_notification' => 0,
    'contact_groups' => 'operations'
  )
end
```
