require 'spec_helper'

describe 'nagios::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
    runner.converge 'nagios::default'
  end
  subject { chef_run }
  before do
    ChefSpec::Server.create_data_bag('users',
                                       'tsmith' => {
                                         'group' => 'sysadmin'
                                       },
                                       'bsmith' => {
                                         'group' => 'users'
                                       }
    )

    stub_command('dpkg -l nagios3').and_return(true)
  end

  it 'should include the server_package recipe' do
    expect(chef_run).to include_recipe 'nagios::server_package'
  end

  it 'should install correction packages' do
    expect(chef_run).to install_package 'nagios3'
  end

  it 'should start and enable service nagios' do
    expect(chef_run).to start_service 'nagios'
    expect(chef_run).to enable_service 'nagios'
  end

end
