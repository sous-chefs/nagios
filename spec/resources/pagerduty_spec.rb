# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'nagios_pagerduty' do
  step_into :nagios_server, :nagios_pagerduty

  context 'on Ubuntu with default paths' do
    platform 'ubuntu', '24.04'

    recipe do
      nagios_server 'default'
      nagios_pagerduty 'default' do
        key 'pagerduty-key'
      end
    end

    before do
      stub_command('dpkg -l nagios4').and_return(true)
      stub_command('/usr/sbin/apache2 -t').and_return(true)
    end

    it { is_expected.to create_if_missing_remote_file('/usr/lib/nagios/plugins/notify_pagerduty.pl') }
    it { is_expected.to create_template('/usr/lib/cgi-bin/nagios4/pagerduty.cgi') }
    it do
      is_expected.to render_file('/usr/lib/cgi-bin/nagios4/pagerduty.cgi')
        .with_content("'command_file' => '/var/lib/nagios4/rw/nagios.cmd'")
    end
    it { is_expected.to create_cron('Flush Pagerduty') }
    it { is_expected.to create_nagios_contact('pagerduty') }
  end

  context 'on Fedora with package paths' do
    platform 'fedora', '32'

    recipe do
      nagios_pagerduty 'package' do
        cgi_bin '/usr/lib64/nagios/cgi-bin'
        command_file '/var/log/nagios/rw/nagios.cmd'
      end
    end

    it { is_expected.to create_template('/usr/lib64/nagios/cgi-bin/pagerduty.cgi') }
    it do
      is_expected.to render_file('/usr/lib64/nagios/cgi-bin/pagerduty.cgi')
        .with_content("'command_file' => '/var/log/nagios/rw/nagios.cmd'")
    end
  end
end
