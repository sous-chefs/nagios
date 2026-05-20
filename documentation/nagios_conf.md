# nagios_conf

Renders a Nagios configuration template into the configured Nagios config directory.

## Actions

- `:create`

## Properties

- `variables`: template variables.
- `config_subdir`: render below the configured object config directory when true.
- `source`: template source file. Defaults to `<resource-name>.cfg.erb`.
- `cookbook`: template cookbook. Defaults to `nagios`.

## Examples

```ruby
nagios_conf 'commands' do
  source 'commands.cfg.erb'
  cookbook 'nagios'
end
```
