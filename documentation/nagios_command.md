# nagios_command

Declares a Nagios command object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the command (default). |
| `:delete` | Removes the command. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios command directives. |

## Examples

```ruby
nagios_command 'check_http' do
  options 'command_line' => '$USER1$/check_http -H $HOSTADDRESS$'
end
```
