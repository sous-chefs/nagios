# nagios_host

Declares a Nagios host object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the host (default). |
| `:delete` | Removes the host. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios host directives. |

## Examples

```ruby
nagios_host 'web01' do
  options(
    'address' => '192.0.2.10',
    'use' => 'server'
  )
end
```
