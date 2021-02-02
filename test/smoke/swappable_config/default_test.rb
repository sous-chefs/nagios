vname =
  if os.name == 'debian'
    'nagios4'
  elsif os.name == 'ubuntu'
    if os.release.to_f < 20.04
      'nagios3'
    else
      'nagios4'
    end
  end

path_conf_dir = if os.redhat?
                  '/etc/nagios'
                else
                  "/etc/#{vname}"
                end

describe file("#{path_conf_dir}/nagios.cfg") do
  it { should exist }
  its(:content) { should include '# Test that we can swap out config files via attributes' }
end
