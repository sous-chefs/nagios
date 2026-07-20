# Nagios Object Resources

Nagios object resources render object definitions through the shared Nagios model.

## Resources

- [nagios_command](nagios_command.md)
- [nagios_contact](nagios_contact.md)
- [nagios_contactgroup](nagios_contactgroup.md)
- [nagios_host](nagios_host.md)
- [nagios_hostdependency](nagios_hostdependency.md)
- [nagios_hostescalation](nagios_hostescalation.md)
- [nagios_hostgroup](nagios_hostgroup.md)
- [nagios_resource](nagios_resource.md)
- [nagios_service](nagios_service.md)
- [nagios_servicedependency](nagios_servicedependency.md)
- [nagios_serviceescalation](nagios_serviceescalation.md)
- [nagios_servicegroup](nagios_servicegroup.md)
- [nagios_timeperiod](nagios_timeperiod.md)

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
