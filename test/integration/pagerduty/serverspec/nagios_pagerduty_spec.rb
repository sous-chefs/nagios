require 'serverspec'

# Required by serverspec
set :backend, :exec

if %w( redhat fedora ).include?(os[:family])
  path_config_dir = '/etc/nagios/conf.d'
else
  path_config_dir = '/etc/nagios3/conf.d'
end

describe 'Pagerduty Configuration' do
  %w(notify-service-by-pagerduty
     notify-host-by-pagerduty).each do |line|
    describe file("#{path_config_dir}/commands.cfg") do
      its(:content) { should match line }
    end
  end

  file_contacts = []
  file_contacts << 'contact.*pagerduty'

  file_contacts.each do |line|
    describe file("#{path_config_dir}/contacts.cfg") do
      its(:content) { should match line }
    end
  end
end

if %w( redhat fedora ).include?(os[:family])
  perl_cgi_package = 'perl-CGI'
  command_file = '/var/log/nagios/rw/nagios.cmd'
else
  perl_cgi_package = 'libcgi-pm-perl'
  command_file = '/var/lib/nagios3/rw/nagios.cmd'
end

describe package(perl_cgi_package) do
  it { should be_installed }
end

if %w( redhat fedora ).include?(os[:family])
  pagerduty_cgi_dir = '/usr/lib64/nagios/cgi-bin'
else
  pagerduty_cgi_dir = '/usr/lib/cgi-bin/nagios3'
end

describe 'Pagerduty Integration Script' do
  describe file("#{pagerduty_cgi_dir}/pagerduty.cgi") do
    its(:content) { should match "'command_file' => '#{command_file}'" }
  end
end
