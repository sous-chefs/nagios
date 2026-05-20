# nagios_apache

Configures Apache as the Nagios web front end and then runs `nagios_configure`.

## Actions

- `:create`

## Examples

```ruby
nagios_server 'default' do
  web_server 'apache'
  enable_ssl true
end
```

Use `nagios_server` for normal cookbook usage. `nagios_apache` is primarily an internal composition resource.
