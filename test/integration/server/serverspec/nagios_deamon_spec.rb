require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Nagios Daemon' do
  it 'has a running service of nagios' do
    expect(service('nagios')).to be_running
  end
end
