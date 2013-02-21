require 'spec_helper'

describe 'nagios::client' do
  let(:chef_run) { runner.converge 'nagios::client' }

  it 'searches for the server ip if no address is provided' do
    Chef::Recipe.any_instance.should_receive(:search).with(:node,
            "role:#{chef_run.node['nagios']['server_role']} AND chef_environment:#{chef_run.node.chef_environment}")

    chef_run
  end

  it 'does not search for the server ip when an address is provided' do
    Chef::Recipe.any_instance.should_not_receive(:search)

    chef_run = runner({
      :nagios => {
        :allowed_hosts => %w(test.host)
      }
    }).converge 'nagios::client'

    expect(chef_run).to create_file_with_content "#{chef_run.node['nagios']['nrpe']['conf_dir']}/nrpe.cfg", 'allowed_hosts=127.0.0.1,test.host'
  end
end
