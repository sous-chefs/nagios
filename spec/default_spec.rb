require 'spec_helper'

describe 'nagios::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
    runner.converge 'nagios::default'
  end
  subject { chef_run }
  before do
    ChefSpec::Server.create_data_bag('users', {
      'tsmith' => {
        'group' => 'sysadmin'
      },
      'bsmith' => {
        'group' => 'users'
      }
    })

    stub_command('dpkg -l nagios3').and_return(true)
  end

  it 'should include apache2 recipe' do
    expect(chef_run).to include_recipe 'apache2'
  end

  it 'should create conf_dir' do
    expect(chef_run).to create_directory chef_run.node['nagios']['conf_dir']
  end

  it 'should template apache2 htpassword file with only admins' do
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/htpasswd.users"
  end

  it 'should template nagios config files' do
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/conf.d/hosts.cfg"
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/conf.d/hostgroups.cfg"
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/conf.d/contacts.cfg"
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/conf.d/servicegroups.cfg"
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/conf.d/services.cfg"
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/cgi.cfg"
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/conf.d/templates.cfg"
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/nagios.cfg"
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/conf.d/timeperiods.cfg"
    expect(chef_run).to render_file "#{chef_run.node['nagios']['conf_dir']}/conf.d/servicedependencies.cfg"
  end

end