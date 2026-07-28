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

  context 'package install on AlmaLinux' do
    platform 'almalinux', '9'

    recipe do
      nagios_server 'package' do
        web_server 'none'
      end
    end

    it { is_expected.to create_yum_epel('default') }
    it { is_expected.to install_package(%w(nagios nagios-plugins-nrpe)) }
  end

  context 'package install on AlmaLinux with EPEL disabled' do
    platform 'almalinux', '9'

    recipe do
      nagios_server 'package' do
        install_yum_epel false
        web_server 'none'
      end
    end

    it { is_expected.not_to create_yum_epel('default') }
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
    it { is_expected.to create_systemd_unit('nagios.service') }

    it 'does not install a SysV init script' do
      expect(chef_run.execute('compile-nagios').command).not_to include('/etc/init.d', 'make install-init')
    end
  end

  context 'source removal on Ubuntu' do
    platform 'ubuntu', '24.04'

    recipe do
      nagios_server 'source' do
        web_server 'none'
        install_method 'source'
        action :delete
      end
    end

    it { is_expected.to delete_systemd_unit('nagios.service') }
    it { is_expected.to delete_file('/usr/sbin/nagios') }
    it { is_expected.to delete_directory('/etc/nagios') }
  end
end
