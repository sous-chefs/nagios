# nagios_nginx

Configures NGINX, PHP-FPM, and CGI dispatch for the Nagios web front end, then runs `nagios_configure`.

## Actions

- `:create`

## Examples

```ruby
nagios_server 'default' do
  web_server 'nginx'
  nginx_dispatch_type 'both'
end
```

OpenID, CAS, and LDAP authentication are not supported with the NGINX front end.
