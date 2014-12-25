require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! do
  add_filter 'vendor/cookbooks'
end
