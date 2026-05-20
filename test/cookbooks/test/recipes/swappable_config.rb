# frozen_string_literal: true

nagios_server 'swappable-config' do
  install_method 'package'
  nagios_config_template_cookbook 'test'
end

include_recipe 'test::objects'
