# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/data_bag'
require 'chef/search/query'

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM

  config.before do
    stub_search('node', 'name:* AND chef_environment:_default').and_return([])

    query = instance_double(Chef::Search::Query)
    allow(query).to receive(:search) do |bag, _expression, &block|
      if bag.to_s == 'users'
        block.call(
          'id' => 'admin',
          'groups' => ['sysadmin'],
          'nagios' => {
            'email' => 'admin@example.com',
            'pager' => 'admin-pager@example.com',
          }
        )
      end
      []
    end

    allow(Chef::Search::Query).to receive(:new).and_return(query)
    allow(Chef::DataBag).to receive(:list).and_return({})
  end
end
