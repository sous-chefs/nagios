require 'serverspec'

# Required by serverspec
set :backend, :exec

svc = if %w( redhat fedora ).include?(os[:family])
        'nagios'
      else
        'nagios3'
      end

describe 'Nagios Daemon' do
  it 'has a running service of nagios' do
    expect(service(svc)).to be_running
  end
end
