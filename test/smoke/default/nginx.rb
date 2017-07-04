# # encoding: utf-8

# Inspec test for recipe nagios::nginx

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

title 'Nginx Checks'

svc = 'nginx'

control 'nginx-deamon-01' do
  impact 1.0
  title 'nginx is running'
  desc 'Verify that the nginx service is running'
  describe service(svc) do
    it { should be_running }
  end
  describe port(80) do
    it { should be_listening }
  end
end

control 'nginx-deamon-02' do
  impact 1.0
  title 'nginx is enabled'
  desc 'Verify that the nginx service is enabled'
  only_if { %w(redhat).include?(os[:family]) }
  describe service(svc) do
    it { should be_enabled }
  end
end
