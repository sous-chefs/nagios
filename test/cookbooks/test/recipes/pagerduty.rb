# frozen_string_literal: true

nagios_server 'pagerduty' do
  install_method 'package'
end

nagios_pagerduty 'pagerduty' do
  key 'your_key_here_3eC2'
end

include_recipe 'test::objects'
