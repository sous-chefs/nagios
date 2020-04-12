path_conf_dir = if os.redhat?
                  '/etc/nagios'
                elsif os.suse?
                  '/etc/nagios3'
                else
                  '/etc/nagios3'
                end

describe file("#{path_conf_dir}/nagios.cfg") do
  it { should exist }
  its(:content) { should include '# Test that we can swap out config files via attributes' }
end
