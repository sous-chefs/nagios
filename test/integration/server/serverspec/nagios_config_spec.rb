require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Nagios Configuration' do
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
    describe file('/etc/nagios/conf.d/commands.cfg') do
      its(:content) { should match line }
    end
  end

  file_services = []
  file_services << 'service_description.*all_hostgroup_service'
  file_services << 'service_description.*load'
  file_services << 'service_description.*service_a'
  file_services << 'service_description.*service_b'
  file_services << 'service_description.*service_c'

  file_services.each do |line|
    describe file('/etc/nagios/conf.d/services.cfg') do
      its(:content) { should match line }
    end
  end

  file_hosts = []
  file_hosts << 'host_name[ \t]+host_a'
  file_hosts << 'host_name[ \t]+host_b'
  file_hosts << 'host_name[ \t]+' + `hostname`.split('.').first

  file_hosts.each do |line|
    describe file('/etc/nagios/conf.d/hosts.cfg') do
      its(:content) { should match line }
    end
  end

  file_contacts = []
  file_contacts << 'contact.*devs'
  file_contacts << 'contact.*root'
  file_contacts << 'contact.*admin'
  file_contacts << 'contactgroup_name.*admins'
  file_contacts << 'contactgroup_name.*admins-sms'

  file_contacts.each do |line|
    describe file('/etc/nagios/conf.d/contacts.cfg') do
      its(:content) { should match line }
    end
  end

  file_hostgroups = []
  file_hostgroups << 'all'
  file_hostgroups << 'linux'
  file_hostgroups << '_default'
  file_hostgroups << 'monitoring'
  file_hostgroups << 'hostgroup_a'
  file_hostgroups << 'hostgroup_b'
  file_hostgroups << 'hostgroup_c'

  file_hostgroups.each do |line|
    describe file('/etc/nagios/conf.d/hostgroups.cfg') do
      its(:content) { should match line }
    end
  end

  file_servicegroups = []
  file_servicegroups << 'servicegroup_name.*servicegroup_a\n\s*members.*host_a,service_a,host_a,service_b,host_b,service_b,host_b,service_c'
  file_servicegroups << 'servicegroup_name.*servicegroup_b\n\s*members.*host_b,service_c'

  file_servicegroups.each do |line|
    describe file('/etc/nagios/conf.d/servicegroups.cfg') do
      its(:content) { should match line }
    end
  end

  file_templates = []
  file_templates << 'define contact {\n\s*name\s*default-contact'
  file_templates << 'define host {\n\s*name\s*default-host'
  file_templates << 'define host {\n\s*name\s*server'
  file_templates << 'define service {\n\s*name\s*default-logfile'
  file_templates << 'define service {\n\s*name\s*default-service'
  file_templates << 'define service {\n\s*name\s*service-template'

  file_templates.each do |line|
    describe file('/etc/nagios/conf.d/templates.cfg') do
      its(:content) { should match line }
    end
  end

  file_timeperiods = []
  file_timeperiods << 'define timeperiod {\n\s*timeperiod_name\s*24x7'

  file_timeperiods.each do |line|
    describe file('/etc/nagios/conf.d/timeperiods.cfg') do
      its(:content) { should match line }
    end
  end
end
