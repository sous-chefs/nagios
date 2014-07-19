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

  it 'should include the php::default recipe' do
    expect(chef_run).to include_recipe 'php::default'
  end

  it 'should include the php::module_gd recipe' do
    expect(chef_run).to include_recipe 'php::module_gd'
  end

  it 'should include source install dependency packages' do
    expect(chef_run).to install_package 'libssl-dev'
    expect(chef_run).to install_package 'libgd2-xpm-dev'
    expect(chef_run).to install_package 'bsd-mailx'
    expect(chef_run).to install_package 'tar'
  end

  it 'should create nagios user and group' do
    expect(chef_run).to create_user 'nagios'
    expect(chef_run).to create_group 'nagios'
  end

  it 'should create nagios directories' do
    expect(chef_run).to create_directory '/etc/nagios3'
    expect(chef_run).to create_directory chef_run.node['nagios']['cache_dir']
    expect(chef_run).to create_directory chef_run.node['nagios']['log_dir']
    expect(chef_run).to create_directory chef_run.node['nagios']['run_dir']
    expect(chef_run).to create_directory '/usr/lib/nagios3'
  end
end
