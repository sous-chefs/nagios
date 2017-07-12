if os.redhat?
  command_file      = '/var/log/nagios/rw/nagios.cmd'
  pagerduty_cgi_dir = '/usr/lib64/nagios/cgi-bin'
  path_config_dir   = '/etc/nagios/conf.d'
  perl_cgi_package  = 'perl-CGI'
else
  command_file      = '/var/lib/nagios3/rw/nagios.cmd'
  pagerduty_cgi_dir = '/usr/lib/cgi-bin/nagios3'
  path_config_dir   = '/etc/nagios3/conf.d'
  perl_cgi_package  = 'libcgi-pm-perl'
end

# PagerDuty Configuration

describe file("#{path_config_dir}/commands.cfg") do
  its(:content) { should match 'notify-(host|service)-by-pagerduty' }
end

describe file("#{path_config_dir}/contacts.cfg") do
  its(:content) { should match 'contact.*pagerduty' }
end

describe package(perl_cgi_package) do
  it { should be_installed }
end

# Test Pagerduty Integration Script

describe file("#{pagerduty_cgi_dir}/pagerduty.cgi") do
  its(:content) { should match "'command_file' => '#{command_file}'" }
end
