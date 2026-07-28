# nagios_servicegroup

Declares a Nagios service group object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the service group (default). |
| `:delete` | Removes the service group. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios service group directives. |

## Examples

```ruby
nagios_servicegroup 'web-services' do
  options(
    'alias' => 'Web Services',
    'members' => 'web01,HTTP,web02,HTTP'
  )
end
```
