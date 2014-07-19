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

  it 'should include apache2 recipe' do
    expect(chef_run).to include_recipe 'apache2'
  end

  it 'should create conf_dir' do
    expect(chef_run).to create_directory '/etc/nagios3'
  end

  it 'should template apache2 htpassword file with only admins' do
    expect(chef_run).to render_file '/etc/nagios3/htpasswd.users'
  end

  it 'should template nagios config files' do
    expect(chef_run).to render_file '/etc/nagios3/conf.d/hosts.cfg'
    expect(chef_run).to render_file '/etc/nagios3/conf.d/hostgroups.cfg'
    expect(chef_run).to render_file '/etc/nagios3/conf.d/contacts.cfg'
    expect(chef_run).to render_file '/etc/nagios3/conf.d/servicegroups.cfg'
    expect(chef_run).to render_file '/etc/nagios3/conf.d/services.cfg'
    expect(chef_run).to render_file '/etc/nagios3/cgi.cfg'
    expect(chef_run).to render_file '/etc/nagios3/conf.d/templates.cfg'
    expect(chef_run).to render_file '/etc/nagios3/nagios.cfg'
    expect(chef_run).to render_file '/etc/nagios3/conf.d/timeperiods.cfg'
    expect(chef_run).to render_file '/etc/nagios3/conf.d/servicedependencies.cfg'
  end

end
