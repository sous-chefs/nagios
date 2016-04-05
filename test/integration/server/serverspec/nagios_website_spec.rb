require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Nagios Website' do
  it 'should be listening on port 80' do
    expect(port(80)).to be_listening
  end

  it 'should return the default homepage' do
    expect { system('wget -qO- --user=admin --password=admin localhost') }.to output(%r{(?i).*<title>Nagios Core</title>.*}).to_stdout_from_any_process
  end

  it 'should have a CGI (sub) page' do
    expect { system('wget -qO- --user=admin --password=admin localhost`wget -qO- --user=admin --password=admin localhost/side.php | grep tac.cgi | awk -F \'"\' \'{print \$2}\'`') }.to output(%r{(?i).*<TITLE>\s*Nagios Tactical Monitoring Overview\s*</TITLE>.*}).to_stdout_from_any_process
  end
end

describe 'Nagios Website Host Configuration' do
  it 'should not contain eventhandler for bighost1' do
    expect { system('wget -qO- --user=admin --password=admin "http://localhost/nagios/cgi-bin/config.cgi?type=hosts&expand=bighost1" | grep my-event-handler-command') }.not_to output(/.*my-event-handler-command.*/i).to_stdout_from_any_process
  end

  it 'should contain eventhandler for bighost2' do
    expect { system('wget -qO- --user=admin --password=admin "http://localhost/nagios/cgi-bin/config.cgi?type=hosts&expand=bighost2" | grep my-event-handler-command') }.to output(/.*type=command.*my-event-handler-command.*/i).to_stdout_from_any_process
  end
end
