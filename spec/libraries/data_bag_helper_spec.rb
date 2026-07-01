# frozen_string_literal: true

require 'spec_helper'
require 'chef/data_bag_item'
require 'chef/search/query'
require_relative '../../libraries/data_bag_helper'

RSpec.describe NagiosDataBags do
  describe '#get' do
    let(:item) do
      item = Chef::DataBagItem.new
      item.data_bag('nagios_services')
      item.raw_data = { 'id' => 'load', 'check_command' => 'check_load' }
      item
    end

    before do
      query = instance_double(Chef::Search::Query)
      allow(Chef::Search::Query).to receive(:new).and_return(query)
      allow(query).to receive(:search).with('nagios_services', '*:*').and_yield(item)
    end

    it 'returns plain, mutable hashes rather than Chef::DataBagItem objects' do
      result = described_class.new(['nagios_services']).get('nagios_services').first
      expect(result).to be_a(Hash)
      expect(result).not_to be_a(Chef::DataBagItem)
      expect(result['check_command']).to eq('check_load')
      # load_services et al. write into the item; that must not raise.
      expect { result['check_command'] = 'check_other' }.not_to raise_error
    end
  end
end
