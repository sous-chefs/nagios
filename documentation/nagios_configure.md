# nagios_configure

Renders Nagios server configuration, creates runtime directories, writes object config files, and enables the Nagios service.

## Actions

- `:create`

## Examples

```ruby
nagios_server 'default' do
  web_server 'none'
end
```

Use `nagios_server` for normal cookbook usage. `nagios_configure` expects `node['nagios']` settings calculated by `nagios_server`.
