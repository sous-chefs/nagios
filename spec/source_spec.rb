require 'spec_helper'

describe 'nagios::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '20.04') do |node, server|
      node.normal['nagios']['server']['install_method'] = 'source'
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
    stub_command('/usr/sbin/apache2 -t').and_return(true)
  end

  it 'should include the server_source recipe' do
    expect(chef_run).to include_recipe('nagios::server_source')
  end

  it 'should include the php::default recipe' do
    expect(chef_run).to include_recipe('php::default')
  end

  it 'should install the php-gd package' do
    expect(chef_run).to install_package('php7.4-gd')
  end

  it 'should include source install dependency packages' do
    expect(chef_run).to install_package(%w(libssl-dev libgdchart-gd2-xpm-dev bsd-mailx tar unzip))
  end

  it 'should create nagios user and group' do
    expect(chef_run).to create_user('nagios')
    expect(chef_run).to create_group('nagios')
  end

  it 'should create nagios directories' do
    expect(chef_run).to create_directory('/etc/nagios')
    expect(chef_run).to create_directory('/etc/nagios/conf.d')
    expect(chef_run).to create_directory('/var/cache/nagios')
    expect(chef_run).to create_directory('/var/log/nagios')
    expect(chef_run).to create_directory('/var/lib/nagios')
    expect(chef_run).to create_directory('/var/run/nagios')
  end
end
