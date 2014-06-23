require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/server'

at_exit { ChefSpec::Coverage.report! }
