path_conf_dir = if os.redhat?
                  '/etc/nagios'
                else
                  '/etc/nagios4'
                end

describe file("#{path_conf_dir}/nagios.cfg") do
  it { should exist }
  its(:content) { should include '# Test that we can swap out config files via attributes' }
end
