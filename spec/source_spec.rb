require 'spec_helper'

describe 'nagios::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
    runner.node.set['nagios']['server']['install_method'] = 'source'
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

  it 'should include the server_source recipe' do
    expect(chef_run).to include_recipe 'nagios::server_source'
  end

end
