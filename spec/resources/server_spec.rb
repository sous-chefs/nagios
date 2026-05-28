# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'nagios_server' do
  step_into :nagios_server, :nagios_apache, :nagios_install, :nagios_configure, :nagios_default_config, :nagios_conf
  platform 'ubuntu', '24.04'

  recipe do
    nagios_server 'default'
  end

  before do
    stub_command('dpkg -l nagios4').and_return(true)
    stub_command('/usr/sbin/apache2 -t').and_return(true)
  end

  it { is_expected.to create_nagios_server('default') }
  it { is_expected.to install_package(%w(nagios4 nagios-nrpe-plugin nagios-images)) }
  it { is_expected.to create_directory('/etc/nagios4') }
  it { is_expected.to create_template('/etc/nagios4/htpasswd.users') }
  it { is_expected.to create_template('/etc/nagios4/nagios.cfg') }
  it { is_expected.to create_template('/etc/nagios4/cgi.cfg') }
  it { is_expected.to create_template('/etc/nagios4/conf.d/timeperiods.cfg') }
  it { is_expected.to enable_service('nagios') }
end

RSpec.describe 'nagios_server with explicit users' do
  step_into :nagios_server, :nagios_apache, :nagios_install, :nagios_configure, :nagios_default_config, :nagios_conf
  platform 'ubuntu', '24.04'

  recipe do
    nagios_server 'default' do
      users [
        {
          id: 'custom-admin',
          htpasswd: '$apr1$custom',
          nagios: {
            email: 'custom-admin@example.com',
            pager: 'custom-admin-pager@example.com',
          },
        },
      ]
    end
  end

  before do
    stub_command('dpkg -l nagios4').and_return(true)
    stub_command('/usr/sbin/apache2 -t').and_return(true)
  end

  it 'uses the configured users instead of searching the users data bag' do
    expect(Chef::Search::Query).not_to receive(:new)

    expect(chef_run.node['nagios'].to_hash).not_to include('users')
    expect(chef_run.template('/etc/nagios4/htpasswd.users').variables[:nagios_users]).to eq(
      [
        {
          'id' => 'custom-admin',
          'htpasswd' => '$apr1$custom',
          'nagios' => {
            'email' => 'custom-admin@example.com',
            'pager' => 'custom-admin-pager@example.com',
          },
        },
      ]
    )
  end
end
