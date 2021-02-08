require 'spec_helper'

describe 'nagios::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '20.04') do |_node, server|
      server.create_data_bag('users',
                                        'user1' => {
                                          'id' => 'tsmith',
                                          'groups' => ['sysadmin'],
                                          'nagios' => {
                                            'pager' => 'nagiosadmin_pager@example.com',
                                            'email' => 'nagiosadmin@example.com',
                                          },
                                        },
                                        'user2' => {
                                          'id' => 'bsmith',
                                          'groups' => ['users'],
                                        })
    end.converge(described_recipe)
  end

  before do
    stub_command('dpkg -l nagios4').and_return(true)
    stub_command('/usr/sbin/apache2 -t').and_return(true)
  end

  it 'should include the server_package recipe' do
    expect(chef_run).to include_recipe('nagios::server_package')
  end

  it 'should install correction packages' do
    expect(chef_run).to install_package(%w(nagios4 nagios-nrpe-plugin nagios-images))
  end

  it do
    expect(chef_run).to enable_service('nagios')
  end
end
