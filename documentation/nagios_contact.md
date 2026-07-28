# nagios_contact

Declares a Nagios contact object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the contact (default). |
| `:delete` | Removes the contact. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios contact directives. |

## Examples

```ruby
nagios_contact 'operations' do
  options(
    'alias' => 'Operations',
    'email' => 'operations@example.com'
  )
end
```
