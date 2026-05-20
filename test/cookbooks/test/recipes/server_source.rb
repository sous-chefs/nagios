# frozen_string_literal: true

nagios_server 'source' do
  install_method 'source'
end

include_recipe 'test::objects'
