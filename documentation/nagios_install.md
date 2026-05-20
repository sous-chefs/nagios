# nagios_install

Installs Nagios packages or compiles Nagios Core from source using settings prepared by `nagios_server`.

## Actions

- `:install`

## Examples

```ruby
nagios_server 'default' do
  install_method 'package'
  web_server 'none'
end
```

Use `nagios_server` for normal cookbook usage. `nagios_install` is primarily an internal composition resource for the server workflow.
