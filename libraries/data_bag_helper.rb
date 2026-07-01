require 'chef/search/query'

# simplified access to databags in the nagios cookbook
class NagiosDataBags
  attr_accessor :bag_list

  def initialize(bag_list = Chef::DataBag.list)
    @bag_list = bag_list
  end

  # Returns an array of data bag items or an empty array
  # Avoids unecessary calls to search by checking against
  # the list of known data bags.
  def get(bag_name)
    results = []
    if @bag_list.include?(bag_name)
      # Return plain (mutable) hashes. Chef::DataBagItem only delegates Hash
      # methods through method_missing and makes #each private on modern Chef
      # Infra clients, so callers that iterate items or write into them (as the
      # load_* helpers do) would otherwise raise.
      Chef::Search::Query.new.search(bag_name.to_s, '*:*') do |row|
        results << (row.respond_to?(:raw_data) ? row.raw_data : row)
      end
    else
      Chef::Log.info "The #{bag_name} data bag does not exist."
    end
    results
  end
end
