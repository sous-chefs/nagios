# nagios_resource

Declares a Nagios resource macro.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the resource macro (default). |
| `:delete` | Removes the resource macro. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios resource directives. |

## Examples

```ruby
nagios_resource 'USER1' do
  options 'value' => '/usr/lib64/nagios/plugins'
end
```
