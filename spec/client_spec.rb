require 'spec_helper'

describe 'nagios::client' do
  let(:chef_run) { runner.converge 'nagios::client' }

  it 'includes the client_package recipe' do
    expect(chef_run).to include_recipe('nagios::client_package')
  end

  it 'installs nagios-nrpe-server package' do
    expect(chef_run).to install_package('nagios-nrpe-server')
  end

  it 'starts nrpe service' do
    expect(chef_run).to start_service('nagios-nrpe-server')
  end

  it 'does not blow up when the search returns no results' do
    Chef::REST.any_instance.stub(:get_rest).and_return('rows' => [], 'start' => 0, 'total' => 0)

    expect { chef_run }.to_not raise_error
  end

  context 'monitoring interface is not set' do
    it 'adds addresses to the allowed hosts when defined' do
      Chef::Recipe.any_instance.stub(:search)

      chef_run = runner(
        :nagios => { :allowed_hosts => %w(test.host) }
        ).converge 'nagios::client'

      expect(chef_run).to render_file("#{chef_run.node['nagios']['nrpe']['conf_dir']}/nrpe.cfg").with_content('allowed_hosts=127.0.0.1,test.host')
    end
  end

  context 'monitoring interface is set' do
    it 'adds monitoring interface to the allowed hosts when defined' do
      Chef::Recipe.any_instance.stub(:search)

      chef_run = runner(
        'nagios' => { 'monitoring_interface' => 'bond.2001', 'ipaddress_bond.2001' => '10.0.0.2', 'server_role' => 'monitoring' }
      )

      chef_run.node.run_list.stub(:roles).and_return ['monitoring']
      chef_run.converge 'nagios::client'

      expect(chef_run).to render_file("#{chef_run.node['nagios']['nrpe']['conf_dir']}/nrpe.cfg").with_content('allowed_hosts=127.0.0.1,10.0.0.2')
    end

    it 'adds node["ipaddress"] when monitoring interface is nil' do
      Chef::Recipe.any_instance.stub(:search)

      chef_run = runner(
        'nagios' => { 'ipaddress_bond.2001' => '10.0.0.2', 'server_role' => 'monitoring' }
      )

      chef_run.node.run_list.stub(:roles).and_return ['monitoring']
      chef_run.converge 'nagios::client'

      expect(chef_run).to render_file("#{chef_run.node['nagios']['nrpe']['conf_dir']}/nrpe.cfg").with_content('allowed_hosts=127.0.0.1')
    end
  end
end
