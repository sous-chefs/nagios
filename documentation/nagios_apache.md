# nagios_apache

Configures Apache as the Nagios web front end and then runs `nagios_configure`.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Configures Apache and Nagios (default). |
| `:delete` | Removes the Apache site and Nagios installation. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `settings` | Hash | required | Server settings prepared by `nagios_server`; behavior-only property. |
| `users` | Array, nil | `nil` | Explicit Nagios UI users. |

## Examples

```ruby
nagios_server 'default' do
  web_server 'apache'
  enable_ssl true
end
```

Use `nagios_server` for normal cookbook usage. `nagios_apache` is primarily an internal composition resource.
