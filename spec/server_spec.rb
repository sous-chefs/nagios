require 'spec_helper'

describe 'nagios::server' do
  let(:chef_run) { runner.converge 'nagios::server' }
  subject { chef_run }
  before do
    stub_search(:users, 'groups:sysadmin NOT action:remove').and_return([])

    stub_search(:node, 'name:* AND chef_environment:test').and_return([])

    stub_search(:role, '*:*').and_return([])

    Chef::DataBag.stub(:list).and_return([])

    # nagios::server_package stubs
    stub_command('dpkg -l nagios3').and_return(true)
  end
  it { should install_package 'nagios3' }
  it { should enable_service 'nagios' }
  it { should start_service 'nagios' }
end
