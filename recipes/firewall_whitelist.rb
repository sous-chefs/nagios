node['munin']['whitelist_ips'].each do |ip|
  firewall_rule "allow #{ip} to access nagios" do
    port 80
    protocol :tcp
    action :allow
    source ip
  end
end
