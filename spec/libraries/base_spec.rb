# frozen_string_literal: true

require 'spec_helper'
require 'chef/data_bag_item'
require 'chef/node/immutable_collections'
require_relative '../../libraries/contact'
require_relative '../../libraries/contactgroup'
require_relative '../../libraries/command'
require_relative '../../libraries/host'
require_relative '../../libraries/hostgroup'

RSpec.describe 'Nagios::Base' do
  before { Nagios.instance.instance_variable_set(:@hostgroups, {}) }

  describe '#update_options with a Chef::DataBagItem' do
    let(:item) do
      item = Chef::DataBagItem.new
      item.data_bag('nagios_contacts')
      item.raw_data = { 'id' => 'epager-contact', 'alias' => 'E Pager', 'email' => 'root@example.org' }
      item
    end

    it 'imports without iterating the item directly' do
      # Modern Chef Infra clients make Chef::DataBagItem#each private, so importing
      # an item must not call #each on it (only on its Hash form).
      allow(item).to receive(:each).and_raise(NoMethodError, "private method 'each' called for a Chef::DataBagItem")

      contact = Nagios::Contact.new('epager-contact')
      expect { contact.import(item) }.not_to raise_error
      expect(contact.email).to eq('root@example.org')
      expect(contact.alias).to eq('E Pager')
    end
  end

  describe '#update_members with an immutable node attribute' do
    it 'does not mutate the caller and never raises ImmutableAttributeModification' do
      # push_node feeds node['nagios'] (an ImmutableMash) into Host#import; the '+'
      # additive-inheritance rewrite must not write back into it.
      attrs = Chef::Node::ImmutableMash.new('hostgroups' => '+linux,web')
      host = Nagios::Host.new('web01')
      expect { host.import(attrs) }.not_to raise_error
      expect(attrs['hostgroups']).to eq('+linux,web') # unchanged
    end
  end

  describe '#check_bool' do
    let(:obj) { Nagios::Command.new('probe') }

    it 'coerces only whole-string truthy values' do
      %w(y yes true on 1).each { |v| expect(obj.send(:check_bool, v)).to eq(1) }
      expect(obj.send(:check_bool, true)).to eq(1)
    end

    it 'does not match substrings such as none or monday' do
      %w(none monday no false 0 yellow).each { |v| expect(obj.send(:check_bool, v)).to eq(0) }
    end
  end

  describe 'Nagios::Command#import' do
    it 'accepts command as an alias for command_line' do
      command = Nagios::Command.new('check_thing')
      command.import('command' => '$USER1$/check_thing')
      expect(command.command_line).to eq('$USER1$/check_thing')
    end
  end
end
