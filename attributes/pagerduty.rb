
unless default['nagios']['additional_contacts'].include? 'pagerduty'
  default['nagios']['additional_contacts'] << 'pagerduty'
end

