# # encoding: utf-8

title 'Nagios Website Checks'

cgi_url = if %w( redhat fedora ).include?(os[:family])
            'http://localhost/nagios/cgi-bin'
          else
            'http://localhost/cgi-bin/nagios3'
          end

control 'nagios-website-01' do
  impact 1.0
  title 'should be listening on port 80'
  desc 'should be listening on port 80'

  describe port(80) do
    it { should be_listening }
  end
end

control 'nagios-website-02' do
  impact 1.0
  title
  desc 'should be listening on port 80'

  describe command('wget -qO- --user=admin --password=admin localhost') do
    its('stdout') { should match %r{<title>Nagios Core</title>} }
    its('exit_status') { should eq 0 }
    its('stdout') do
      should match(%r{<title>Nagios Core(.*)?<\/title>})
    end
  end
end

control 'nagios-website-03' do
  impact 1.0
  title 'should have a CGI (sub) page'
  desc 'should have a CGI (sub) page'

  describe command("wget -qO- --user=admin --password=admin #{cgi_url}/tac.cgi") do
    its('stdout') { should match %r{<TITLE>\s*Nagios Tactical Monitoring Overview\s*</TITLE>} }
    its('exit_status') { should eq 0 }
    its('stdout') do
      should match(%r{<TITLE>\s*Nagios Tactical Monitoring Overview\s*</TITLE>})
    end
  end
end

control 'nagios-website-04' do
  impact 1.0
  title 'should not contain eventhandler for bighost1'
  desc 'should not contain eventhandler for bighost1'

  describe command("#{cgi_cmd}/config.cgi?'type=hosts&expand=bighost1'") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not match(/.*my-event-handler-command.*/i) }
  end
end

control 'nagios-website-05' do
  impact 1.0
  title 'should contain eventhandler for bighost2'
  desc 'should contain eventhandler for bighost2'

  describe command("#{cgi_cmd}/config.cgi?'type=hosts&expand=bighost2'") do
    its('stdout') { should match(/.*my-event-handler-command.*/i) }
    its('exit_status') { should eq 0 }
  end
end
