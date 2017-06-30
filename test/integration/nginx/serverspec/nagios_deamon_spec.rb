require 'serverspec'

# Required by serverspec
set :backend, :exec

svc='nagios3'

describe 'Nagios Daemon' do
  it 'has a running service of nagios' do
    expect(service(svc)).to be_running
  end
end
