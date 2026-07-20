# nagios_configure

Renders Nagios server configuration, creates runtime directories, writes object config files, and enables the Nagios service.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Renders configuration and enables the service (default). |
| `:delete` | Stops the service and removes generated configuration. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `settings` | Hash | required | Server settings prepared by `nagios_server`; behavior-only property. |
| `users` | Array, nil | `nil` | Explicit Nagios UI users. |

## Examples

```ruby
nagios_server 'default' do
  web_server 'none'
end
```

Use `nagios_server` for normal cookbook usage. It passes resource-local settings to
`nagios_configure`; the cookbook does not persist configuration in node attributes.
