require 'serverspec'

# Required by serverspec
set :backend, :exec

if %w( redhat fedora ).include?(os[:family])
  svc='nagios'
else
  svc='nagios3'
end

describe 'Nagios Daemon' do
  it 'has a running service of nagios' do
    expect(service(svc)).to be_running
  end
end
