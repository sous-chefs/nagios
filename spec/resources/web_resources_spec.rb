# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Nagios web resources' do
  context 'apache front end' do
    step_into :nagios_server, :nagios_apache
    platform 'ubuntu', '24.04'

    recipe do
      nagios_server 'apache'
    end

    before do
      stub_command('dpkg -l nagios4').and_return(true)
      stub_command('/usr/sbin/apache2 -t').and_return(true)
    end

    it { is_expected.to install_apache2_install('nagios') }
    it { is_expected.to enable_apache2_site('nagios4') }
  end

  context 'nginx front end' do
    step_into :nagios_server, :nagios_nginx
    platform 'ubuntu', '24.04'

    recipe do
      nagios_server 'nginx' do
        web_server 'nginx'
      end
    end

    before do
      stub_command('dpkg -l nagios4').and_return(true)
    end

    it { is_expected.to install_nginx_install('nagios') }
    it { is_expected.to enable_nginx_site('nagios') }
  end
end
