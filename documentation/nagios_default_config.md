# nagios_default_config

Creates the default Nagios commands, contacts, host templates, hosts, and service definitions from Chef node search.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Creates default Nagios objects (default). |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `settings` | Hash | required | Server settings prepared by `nagios_server`; behavior-only property. |
| `users` | Array, nil | `nil` | Explicit users, replacing the users data bag search. |

## Examples

```ruby
nagios_server 'default' do
  load_default_config true
end
```

Disable this when Chef search is unavailable:

```ruby
nagios_server 'default' do
  load_default_config false
end
```
