# nagios_timeperiod

Declares a Nagios time period object.

## Actions

| Action | Description |
| --- | --- |
| `:create` | Adds or updates the time period (default). |
| `:delete` | Removes the time period. |

## Properties

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | Hash, Chef::DataBagItem | `{}` | Nagios time period directives. |

## Examples

```ruby
nagios_timeperiod 'business-hours' do
  options(
    'alias' => 'Business Hours',
    'times' => {
      'monday' => '09:00-17:00',
      'tuesday' => '09:00-17:00',
    }
  )
end
```
