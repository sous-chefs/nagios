# nagios_default_config

Creates the default Nagios commands, contacts, host templates, hosts, and service definitions from Chef node search.

## Actions

- `:create`

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
