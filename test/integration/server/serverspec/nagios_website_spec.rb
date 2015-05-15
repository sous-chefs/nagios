require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Nagios Website' do
  it 'should be listening on port 80' do
    expect(port 80).to be_listening
  end

  it 'should return the default homepage' do
    expect { system('curl -s --basic --user admin:admin localhost') }.to output(/(?i).*<title>Nagios Core<\/title>.*/).to_stdout_from_any_process
  end

  it 'should have a CGI (sub) page' do
    expect { system('curl -s --basic --user admin:admin localhost`curl -s --basic --user admin:admin localhost/side.php | grep tac.cgi | awk -F \'"\' \'{print \$2}\'`') }.to output(/(?i).*<TITLE>\s*Nagios Tactical Monitoring Overview\s*<\/TITLE>.*/).to_stdout_from_any_process
  end
end

