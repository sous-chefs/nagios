# nagios_conf

Renders a Nagios configuration template into the configured Nagios config directory.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Renders the configuration file (default). |
| `:delete` | Deletes the configuration file. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `variables` | Hash | `{}` | Template variables. |
| `config_subdir` | true, false | `true` | Use `config_dir`; otherwise use `conf_dir`. |
| `source` | String, nil | `<name>.cfg.erb` | Template source file. |
| `cookbook` | String | `'nagios'` | Template cookbook. |
| `conf_dir` | String | required | Main Nagios configuration directory. |
| `config_dir` | String | required | Nagios object configuration directory. |
| `owner` | String | `'nagios'` | File owner. |
| `group` | String | `'nagios'` | File group. |
| `service_name` | String | `'nagios'` | Chef service resource notified on changes. |

## Examples

```ruby
nagios_conf 'commands' do
  conf_dir '/etc/nagios'
  config_dir '/etc/nagios/conf.d'
  source 'commands.cfg.erb'
  cookbook 'nagios'
end
```
