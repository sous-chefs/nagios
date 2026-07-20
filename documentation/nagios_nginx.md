# nagios_nginx

Configures NGINX, PHP-FPM, and CGI dispatch for the Nagios web front end, then runs `nagios_configure`.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Configures NGINX and Nagios (default). |
| `:delete` | Removes the NGINX site and Nagios installation. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `settings` | Hash | required | Server settings prepared by `nagios_server`; behavior-only property. |
| `users` | Array, nil | `nil` | Explicit Nagios UI users. |

## Examples

```ruby
nagios_server 'default' do
  web_server 'nginx'
  nginx_dispatch_type 'both'
end
```

OpenID, CAS, and LDAP authentication are not supported with the NGINX front end.
