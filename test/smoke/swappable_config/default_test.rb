if os.redhat?
    path_conf_dir   = '/etc/nagios'
elsif os.suse?
    path_conf_dir   = '/etc/nagios3'
else
    path_conf_dir   = '/etc/nagios3'
end

describe file("#{path_conf_dir}/nagios.cfg") do
    it { should exist }
    its(:content) { should include '# Test that we can swap out config files via attributes' }
end
