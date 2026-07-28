# nagios_data_bag_config

Loads Nagios objects from configured data bags.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Loads configured data bags into Nagios objects (default). |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `settings` | Hash | required | Server and data bag settings prepared by `nagios_server`; behavior-only property. |

## Data Bags

The data bag names are set on `nagios_server` properties such as `services_databag`, `hostgroups_databag`, `contacts_databag`, and `timeperiods_databag`.

## Examples

```ruby
nagios_server 'default' do
  load_databag_config true
  services_databag 'nagios_services'
end
```
