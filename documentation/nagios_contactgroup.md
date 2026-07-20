# nagios_contactgroup

Declares a Nagios contact group object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the contact group (default). |
| `:delete` | Removes the contact group. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios contact group directives. |

## Examples

```ruby
nagios_contactgroup 'operations' do
  options(
    'alias' => 'Operations',
    'members' => 'alice,bob'
  )
end
```
