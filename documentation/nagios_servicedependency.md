# nagios_servicedependency

Declares a Nagios service dependency object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the dependency (default). |
| `:delete` | Removes the dependency. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios service dependency directives. |

## Examples

```ruby
nagios_servicedependency 'application-on-database' do
  options(
    'host_name' => 'database01',
    'service_description' => 'PostgreSQL',
    'dependent_host_name' => 'application01',
    'dependent_service_description' => 'Application'
  )
end
```
