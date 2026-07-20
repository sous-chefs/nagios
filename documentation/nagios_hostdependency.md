# nagios_hostdependency

Declares a Nagios host dependency object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the dependency (default). |
| `:delete` | Removes the dependency. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios host dependency directives. |

## Examples

```ruby
nagios_hostdependency 'database-on-router' do
  options(
    'host_name' => 'router01',
    'dependent_host_name' => 'database01'
  )
end
```
