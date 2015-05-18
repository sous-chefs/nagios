require 'serverspec'

# Required by serverspec
set :backend, :exec

if %w( redhat fedora ).include?(os[:family])
  path_config_dir    = '/etc/nagios/conf.d'
else
  path_config_dir    = '/etc/nagios3/conf.d'
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
