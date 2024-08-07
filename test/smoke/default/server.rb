# Inspec test for recipe nagios::server

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

title 'Nagios Server Checks'

install_method = input('install_method')

vname =
  if install_method == 'source'
    'nagios'
  elsif os.name == 'debian'
    'nagios4'
  elsif os.name == 'ubuntu'
    'nagios4'
  end

if %w(redhat).include?(os[:family])
  path_config_dir    = '/etc/nagios/conf.d'
  path_conf_dir      = '/etc/nagios'
  svc = 'nagios'
else
  path_config_dir    = "/etc/#{vname}/conf.d"
  path_conf_dir      = "/etc/#{vname}"
  svc = vname
end

control 'nagios-deamon-01' do
  impact 1.0
  title 'nagios is running'
  desc 'Verify that the nagios service is running'
  describe service(svc) do
    it { should be_running }
  end
  only_if { !(os.redhat? && os[:release].start_with?('6')) }
end

control 'nagios-deamon-02' do
  impact 1.0
  title 'nagios is enabled'
  desc 'Verify that the nagios service is enabled'
  only_if { %w(redhat ubuntu).include?(os[:family]) }
  describe service(svc) do
    it { should be_enabled }
  end
end

control 'nagios-config-01' do
  impact 1.0
  title 'commands.cfg'
  desc 'Validate commands.cfg file'

  %w(check_all_hostgroup_service
     check_host_alive
     check_load
     check_nagios
     check_nrpe
     check_nrpe_alive
     check_service_a
     check_service_b
     check_service_c
     host_notify_by_email
     host_notify_by_sms_email
     service_notify_by_email).each do |line|
    describe file("#{path_config_dir}/commands.cfg") do
      its('content') { should match line }
    end
  end
end

control 'nagios-config-02' do
  impact 1.0
  title 'nagios.cfg'
  desc 'Validate nagios.cfg file'

  file_nagios_config = []
  file_nagios_config << 'host_perfdata_command=command_a'
  file_nagios_config << 'host_perfdata_command=command_b'
  file_nagios_config << 'use_syslog=0'

  file_nagios_config.each do |line|
    describe file("#{path_conf_dir}/nagios.cfg") do
      its('content') { should match line }
    end
  end
end

control 'nagios-config-03' do
  impact 1.0
  title 'nagios.cfg'
  desc 'Validate nagios.cfg file'

  file_nagios_config = []
  file_nagios_config << 'query_socket='

  file_nagios_config.each do |line|
    describe file("#{path_conf_dir}/nagios.cfg") do
      its('content') { should_not match line }
    end
  end
end

control 'nagios-config-04' do
  impact 1.0
  title 'service.cfg'
  desc 'Validate service.cfg file'

  file_services = []
  file_services << 'service_description.*all_hostgroup_service'
  file_services << 'service_description.*load'
  file_services << 'service_description.*service_a'
  file_services << 'service_description.*service_b'
  file_services << 'service_description.*service_c'
  file_services << 'check_command.*system-load!15,10,5!30,25,20'
  file_services << 'contact_groups.*\+[^ ]+non_admins'
  file_services << 'contact_groups.*null'
  file_services << 'host_name.*\*'

  file_services.each do |line|
    describe file("#{path_config_dir}/services.cfg") do
      its('content') { should match line }
    end
  end
end

control 'nagios-config-05' do
  impact 1.0
  title 'hosts.cfg'
  desc 'Validate hosts.cfg file'

  file_hosts = []
  file_hosts << 'host_name[ \t]+host_a_alt'
  file_hosts << 'host_name[ \t]+host_b'
  ## file_hosts << 'host_name[ \t]+' + `hostname`.split('.').first
  file_hosts << 'host_name[ \t]+chefnode_a'
  file_hosts << '_CUSTOM_HOST_OPTION[ \t]+custom_host_value.*\n}'
  file_hosts << 'notes[ \t]+configured via chef node attributes'
  file_hosts << 'host_name[ \t]+chefnode_b_alt'
  file_hosts << 'host_name[ \t]+chefnode_c_alt'
  file_hosts << 'host_name[ \t]+chefnode_d_alt'

  file_hosts.each do |line|
    describe file("#{path_config_dir}/hosts.cfg") do
      its('content') { should match line }
    end
  end
end

control 'nagios-config-06' do
  impact 1.0
  title 'hosts.cfg exclude'
  desc 'Validate hosts.cfg file'

  file_hosts_exclude = []
  file_hosts_exclude << 'chefnode_exclude_arr'
  file_hosts_exclude << 'chefnode_exclude_str'
  file_hosts_exclude << 'host_name.*\*'

  file_hosts_exclude.each do |line|
    describe file("#{path_config_dir}/hosts.cfg") do
      its('content') { should_not match line }
    end
  end
end

control 'nagios-config-07' do
  impact 1.0
  title 'contacts.cfg'
  desc 'Validate contacts.cfg file'

  file_contacts = []
  file_contacts << 'contact.*devs'
  file_contacts << 'contact.*root'
  file_contacts << 'contact.*admin'
  file_contacts << 'contactgroup_name.*admins'
  file_contacts << 'contactgroup_name.*admins-sms'

  file_contacts.each do |line|
    describe file("#{path_config_dir}/contacts.cfg") do
      its('content') { should match line }
    end
  end
end

control 'nagios-config-08' do
  impact 1.0
  title 'contacts.cfg exclude'
  desc 'Validate contacts.cfg file'

  file_contacts_exclude = []
  file_contacts_exclude << 'contact_group.*\+non_admins'
  file_contacts_exclude << 'contact_group.*null'

  file_contacts_exclude.each do |line|
    describe file("#{path_config_dir}/contacts.cfg") do
      its('content') { should_not match line }
    end
  end
end

control 'nagios-config-09' do
  impact 1.0
  title 'hostgroups.cfg'
  desc 'Validate hostgroups.cfg file'

  file_hostgroups = []
  file_hostgroups << 'all'
  file_hostgroups << 'linux'
  file_hostgroups << '_default'
  file_hostgroups << 'monitoring'
  file_hostgroups << 'hostgroup_a'
  file_hostgroups << 'hostgroup_b'
  file_hostgroups << 'hostgroup_c'

  file_hostgroups.each do |line|
    describe file("#{path_config_dir}/hostgroups.cfg") do
      its('content') { should match line }
    end
  end
end

control 'nagios-config-10' do
  impact 1.0
  title 'servicegroups.cfg'
  desc 'Validate servicegroups.cfg file'

  file_servicegroups = []
  file_servicegroups << 'servicegroup_name.*servicegroup_a\n\s*members.*' \
    'host_a_alt,service_a,host_a_alt,service_b,host_b,service_b,host_b,' \
    'service_c'
  file_servicegroups << 'servicegroup_name.*servicegroup_b\n\s*members.*' \
    'host_b,service_c'
  file_servicegroups << 'servicegroup_name.*selective_services\n\s*members\s*' \
    '.*host_b,selective_service'

  file_servicegroups.each do |line|
    describe file("#{path_config_dir}/servicegroups.cfg") do
      its('content') { should match line }
    end
  end
end

control 'nagios-config-11' do
  impact 1.0
  title 'templates.cfg'
  desc 'Validate templates.cfg file'

  file_templates = []
  file_templates << 'define contact {\n\s*name\s*default-contact'
  file_templates << 'define host {\n\s*name\s*default-host'
  file_templates << 'define host {\n\s*name\s*server'
  file_templates << 'define service {\n\s*name\s*default-logfile'
  file_templates << 'define service {\n\s*name\s*default-service'
  file_templates << 'define service {\n\s*name\s*service-template'

  file_templates.each do |line|
    describe file("#{path_config_dir}/templates.cfg") do
      its('content') { should match line }
    end
  end
end

control 'nagios-config-12' do
  impact 1.0
  title 'timeperiods.cfg'
  desc 'Validate timeperiods.cfg file'

  file_timeperiods = []
  file_timeperiods << 'define timeperiod {\n\s*timeperiod_name\s*24x7'
  file_timeperiods << 'Joshua Skains\n  sunday           09:00-17:00'

  file_timeperiods.each do |line|
    describe file("#{path_config_dir}/timeperiods.cfg") do
      its('content') { should match line }
    end
  end
end
