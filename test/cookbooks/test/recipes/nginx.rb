# frozen_string_literal: true

nagios_server 'nginx' do
  web_server 'nginx'
  stop_apache true
end

include_recipe 'test::objects'
