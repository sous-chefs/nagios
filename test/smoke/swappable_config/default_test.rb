describe file('/etc/nagios/nagios.cfg') do
  it { should exist }
  its(:content) { should include '# Test that we can swap out config files via attributes' }
end
