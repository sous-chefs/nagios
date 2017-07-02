# # encoding: utf-8

# Inspec test for recipe nagios::nginx

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

title 'Nginx Checks'

svc='nginx'

control 'nginx-deamon-01' do
  impact 1.0
  title 'nginx is enabled and running'
  desc 'Verify that the nginx service is enabled and running'
  describe service(svc) do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(80) do
    it { should be_listening }
    its('processes') { should include "#{svc}.conf" }
  end
end
