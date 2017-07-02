# # encoding: utf-8

# Inspec test for recipe nagios::apache

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

title 'Apache Checks'

svc = if %w( redhat fedora ).include?(os[:family])
        'httpd'
      else
        'apache2'
      end

control 'apache-deamon-01' do
  impact 1.0
  title 'apache is enabled and running'
  desc 'Verify that the apache service is enabled and running'
  describe service(svc) do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(80) do
    it { should be_listening }
    its('processes') { should include svc }
  end
end
