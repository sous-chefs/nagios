# nagios_service

Declares a Nagios service object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the service (default). |
| `:delete` | Removes the service. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios service directives. |

## Examples

```ruby
nagios_service 'http-web01' do
  options(
    'host_name' => 'web01',
    'service_description' => 'HTTP',
    'check_command' => 'check_http'
  )
end
```
