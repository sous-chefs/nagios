require 'spec_helper'

describe 'nagios::client' do
  let(:chef_run) { runner.converge 'nagios::client' }

  it 'adds addresses to the allowed hosts when defined' do
    Chef::Recipe.any_instance.stub(:search)

    chef_run = runner({
      :nagios => {
        :allowed_hosts => %w(test.host)
      }
    }).converge 'nagios::client'

    expect(chef_run).to create_file_with_content "#{chef_run.node['nagios']['nrpe']['conf_dir']}/nrpe.cfg", 'allowed_hosts=127.0.0.1,test.host'
  end

  it 'does not blow up when the search returns no results' do
    Chef::REST.any_instance.stub(:get_rest).and_return({"rows"=>[], "start"=>0, "total"=>0})

    lambda { chef_run }.should_not raise_error
  end
end
