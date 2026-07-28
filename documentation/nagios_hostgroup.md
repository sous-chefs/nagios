# nagios_hostgroup

Declares a Nagios host group object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the host group (default). |
| `:delete` | Removes the host group. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios host group directives. |

## Examples

```ruby
nagios_hostgroup 'web-servers' do
  options(
    'alias' => 'Web Servers',
    'members' => 'web01,web02'
  )
end
```
