if os.redhat?
  apache_bin      = 'httpd'
  config_cgi_path = 'nagios/cgi-bin/config.cgi'
  path_config_dir = '/etc/nagios/conf.d'
  path_conf_dir   = '/etc/nagios'
  service_name    = 'nagios'
elsif os.suse?
  apache_bin      = 'httpd-prefork'
  config_cgi_path = 'cgi-bin/nagios3/config.cgi'
  path_config_dir = '/etc/nagios3/conf.d'
  path_conf_dir   = '/etc/nagios3'
  service_name    = 'nagios'
else
  apache_bin      = 'apache2'
  config_cgi_path = 'cgi-bin/nagios3/config.cgi'
  path_config_dir = '/etc/nagios3/conf.d'
  path_conf_dir   = '/etc/nagios3'
  service_name    = 'nagios3'
end

# Test Nagios Config

describe file("#{path_config_dir}/commands.cfg") do
  its(:content) { should match 'check_all_hostgroup_service' }
  its(:content) { should match 'check_host_alive' }
  its(:content) { should match 'check_load' }
  its(:content) { should match 'check_nagios' }
  its(:content) { should match 'check_nrpe' }
  its(:content) { should match 'check_nrpe_alive' }
  its(:content) { should match 'check_service_(a|b|c)' }
  its(:content) { should match 'host_notify_by_email' }
  its(:content) { should match 'host_notify_by_sms_email' }
  its(:content) { should match 'service_notify_by_email' }
end

describe file("#{path_conf_dir}/nagios.cfg") do
  its(:content) { should match 'host_perfdata_command=command_(a|b)' }
  its(:content) { should match 'use_syslog=0' }
end

describe file("#{path_conf_dir}/nagios.cfg") do
  its(:content) { should_not match 'query_socket=' }
end

describe file("#{path_config_dir}/services.cfg") do
  its(:content) { should match 'service_description.*all_hostgroup_service' }
  its(:content) { should match 'service_description.*load' }
  its(:content) { should match 'service_description.*service_(a|b|c)' }
  its(:content) { should match 'check_command.*system-load!15,10,5!30,25,20' }
  its(:content) { should match 'contact_groups.*\+[^ ]+non_admins' }
  its(:content) { should match 'contact_groups.*null' }
  its(:content) { should match 'host_name.*\*' }
end

describe file("#{path_config_dir}/hosts.cfg") do
  its(:content) { should match 'host_name[ \t]+host_a_alt' }
  its(:content) { should match 'host_name[ \t]+host_b' }
  its(:content) { should match 'host_name[ \t]+chefnode_a' }
  its(:content) { should match 'host_name[ \t]+chefnode_(b|c|d)_alt' }
  its(:content) { should match '_CUSTOM_HOST_OPTION[ \t]+custom_host_value.*\n}' }
  its(:content) { should match 'notes[ \t]+configured via chef node attributes' }
end

describe file("#{path_config_dir}/hosts.cfg") do
  its(:content) { should_not match 'chefnode_exclude_(arr|str)' }
  its(:content) { should_not match 'host_name.*\*' }
end

describe file("#{path_config_dir}/contacts.cfg") do
  its(:content) { should match 'contact.*(admin|devs|root)' }
  its(:content) { should match 'contactgroup_name.*admins' }
  its(:content) { should match 'contactgroup_name.*admins-sms' }
end

describe file("#{path_config_dir}/contacts.cfg") do
  its(:content) { should_not match 'contact_group.*\+non_admins' }
  its(:content) { should_not match 'contact_group.*null' }
end

describe file("#{path_config_dir}/hostgroups.cfg") do
  its(:content) { should match 'all' }
  its(:content) { should match 'linux' }
  its(:content) { should match '_default' }
  its(:content) { should match 'monitoring' }
  its(:content) { should match 'hostgroup_(a|b|c)' }
end

describe file("#{path_config_dir}/servicegroups.cfg") do
  its(:content) { should match "servicegroup_name.*servicegroup_a\n\s*members.*host_a_alt,service_a,host_a_alt,service_b,host_b_alt,service_b,host_b_alt,service_c" }
  its(:content) { should match "servicegroup_name.*servicegroup_b\n\s*members.*host_b_alt,service_c" }
  its(:content) { should match "servicegroup_name.*selective_services\n\s*members\s*host_a_alt,selective_service,host_b_alt,selective_service" }
end

describe file("#{path_config_dir}/templates.cfg") do
  its(:content) { should match 'define contact {\n\s*name\s*default-contact' }
  its(:content) { should match 'define host {\n\s*name\s*default-host' }
  its(:content) { should match 'define host {\n\s*name\s*server' }
  its(:content) { should match 'define service {\n\s*name\s*default-logfile' }
  its(:content) { should match 'define service {\n\s*name\s*default-service' }
  its(:content) { should match 'define service {\n\s*name\s*service-template' }
end

describe file("#{path_config_dir}/timeperiods.cfg") do
  its(:content) { should match "define timeperiod {\n\s\stimeperiod_name\s\s24x7" }
  its(:content) { should match "Joshua Skains\n  sunday           09:00-17:00" }
end

# Test Nagios Daemon

describe service(service_name) do
  it { should be_enabled }
  it { should be_running }
end

# Test Nagios Website

describe port(80) do
  it { should be_listening }
  its('processes') { should include apache_bin }
end

describe command('wget -qO- --user=admin --password=admin localhost') do
  its(:stdout) { should match %r{(?i).*<title>Nagios Core.*</title>.*} }
end

# This looks wrong and can't make it work - perhaps someone can take a look or decide to remove this test entirely?
# describe command('wget -qO- --user=admin --password=admin localhost`wget -qO- --user=admin --password=admin localhost/side.php | grep tac.cgi | awk -F \'"\' \'{print \$2}\'`') do
#   its(:stdout) { should match %r{(?i).*<TITLE>\s*Nagios Tactical Monitoring Overview\s*</TITLE>.*} }
# end

# Test Nagios Website Host Configuration

describe command("wget -qO- --user=admin --password=admin \"http://localhost/#{config_cgi_path}?type=hosts&expand=bighost1\" | grep my-event-handler-command") do
  its(:stdout) { should_not match 'my-event-handler-command' }
end

describe command("wget -qO- --user=admin --password=admin \"http://localhost/#{config_cgi_path}?type=hosts&expand=bighost2\" | grep my-event-handler-command") do
  its(:stdout) { should match 'type=command.*my-event-handler-command' }
end
