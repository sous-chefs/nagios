# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'nagios_install' do
  step_into :nagios_server, :nagios_install

  context 'package install on Ubuntu' do
    platform 'ubuntu', '24.04'

    recipe do
      nagios_server 'package' do
        web_server 'none'
      end
    end

    before do
      stub_command('dpkg -l nagios4').and_return(true)
    end

    it { is_expected.to install_package(%w(nagios4 nagios-nrpe-plugin nagios-images)) }
  end

  context 'source install on Ubuntu' do
    platform 'ubuntu', '24.04'

    recipe do
      nagios_server 'source' do
        web_server 'none'
        install_method 'source'
      end
    end

    it { is_expected.to install_php_install('nagios') }
    it { is_expected.to install_package('php8.3-gd') }
    it { is_expected.to create_user('nagios') }
    it { is_expected.to create_group('nagios') }
    it { is_expected.to create_remote_file('nagios source file') }
  end
end
