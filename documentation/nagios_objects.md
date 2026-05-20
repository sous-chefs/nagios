# Nagios Object Resources

Nagios object resources render object definitions through the shared Nagios model.

## Resources

- `nagios_command`
- `nagios_contact`
- `nagios_contactgroup`
- `nagios_host`
- `nagios_hostdependency`
- `nagios_hostescalation`
- `nagios_hostgroup`
- `nagios_resource`
- `nagios_service`
- `nagios_servicedependency`
- `nagios_serviceescalation`
- `nagios_servicegroup`
- `nagios_timeperiod`

## Actions

- `:create`
- `:delete`

## Properties

- `options`: hash or `Chef::DataBagItem` containing Nagios object options.

## Examples

```ruby
nagios_command 'check_http' do
  options(
    'command_line' => '$USER1$/check_http -H $HOSTADDRESS$'
  )
end

nagios_host 'web01' do
  options(
    'address' => '192.0.2.10',
    'use' => 'server'
  )
end

nagios_service 'http-web01' do
  options(
    'host_name' => 'web01',
    'service_description' => 'HTTP',
    'check_command' => 'check_http'
  )
end
```
