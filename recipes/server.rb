#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: server
#
# Copyright 2009, 37signals
# Copyright 2009-2011, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "java"

include_recipe "perl"
include_recipe "zookeeper_tealium::client_python"
include_recipe "tealium_bongo::packages"
include_recipe "pnp4nagios_tealium"
include_recipe "nagios::nsca_server"

%w{make libnet-nslookup-perl libmodule-install-perl libyaml-perl libyaml-syck-perl libwww-perl libnagios-plugin-perl java-jmxterm}.each do |pkg|    
    package pkg do
        action :install
    end
end

[
   "LWP::UserAgent::DNS::Hosts"
].each { |package|
    cpan_module package
}

web_srv = node['nagios']['server']['web_server'].to_sym

case web_srv
when :nginx
    Chef::Log.info "Setting up Nagios server via NGINX"
    include_recipe 'nagios::nginx'
    web_user = node["nginx"]["user"]
    web_group = node["nginx"]["group"] || web_user
when :apache
    Chef::Log.info "Setting up Nagios server via Apache2"
    include_recipe 'nagios::apache'
    web_user = node["apache"]["user"]
    web_group = node["apache"]["group"] || web_user
else
    Chef::Log.fatal("Unknown web server option provided for Nagios server: " <<
        "#{node['nagios']['server']['web_server']} provided. Allowed: :nginx or :apache"
    )
    raise 'Unknown web server option provided for Nagios server'
end

# Install nagios either from source of package
include_recipe "nagios::server_#{node['nagios']['server']['install_method']}"


unless node['instance_role'] == 'vagrant'
    tries = 3
    begin
        sysadmins = search(:users, 'groups:sysadmin')
        nagiosadmins = search(:users, 'group:devops')
    rescue Net::HTTPServerException => err
        Chef::Log.info("Search for all sysadmin users or devops group members failed with: #{err}")
        tries -= 1
        if tries > 0
            Chef::Log.info("Retrying")
            retry
        else
            Chef::Log.error("Tried a few times and we keep getting exceptions talking to chef API.  Bailing out")
            raise err
        end
    end
    admins = sysadmins.concat(nagiosadmins)
else
    sysadmins = ["nagiosadmin"]
end

case node['nagios']['server_auth_method']
when "openid"
    if(web_srv == :apache)
        include_recipe "apache2::mod_auth_openid"
    else
        Chef::Log.fatal("OpenID authentication for Nagios is not supported on NGINX")
        Chef::Log.fatal("Set node['nagios']['server_auth_method'] attribute in your role: #{node['nagios']['server_role']}")
        raise "OpenID authentication for Nagios is not supported on NGINX"
    end
else
    template "#{node['nagios']['conf_dir']}/htpasswd.users" do
        source "htpasswd.users.erb"
        owner node['nagios']['user']
        group web_group
        mode 0640
        variables(
            :sysadmins => admins
        )
    end
end

directory "#{node['nagios']['docroot_pub']}" do
    owner node['nagios']['user']
    group node['nagios']['group']
    mode 00755
end

template "#{node['nagios']['docroot_pub']}/index.html" do
    source "index.html.erb"
    owner node['nagios']['user']
    group web_group
    mode 0644
end

template "/tmp/mongo_call.js" do
    source "mongo_call.js.erb"
    owner node['nagios']['user']
    group node['nagios']['group']
    mode 0777
end

region = node[:ec2][:region]

#node.set['domain'] = "prod1.eu-c1.int.ops.tlium.com"

domain = DNSHelpers.get_domain(node)

Chef::Log.warn(" ###############Domain is #{domain}. ##################")


#nodes = search(:node, "app_environment:#{node['app_environment']} AND domain:#{node['domain']}")

#Chef::Log.warn("Nagios Nodes are #{nodes}.")

#vnodes = search(:node, "app_environment:#{node['app_environment']} AND domain:v*")

#Chef::Log.warn("Nagios vNodes are #{vnodes}.")

#nodes = vnodes.concat(nodes)



unless domain.match(/^prod1?.\w{2}-\w{2}/)

    tries = 3
    begin
        nodes = search(:node, "app_environment:production AND placement_availability_zone:#{region}* NOT domain:prod*")
    rescue Net::HTTPServerException => err
        Chef::Log.info("Search for all roles failed with: #{err}")
        tries -= 1
        if tries > 0
            Chef::Log.info("Retrying")
            retry
        else
            Chef::Log.error("Tried a few times and we keep getting exceptions talking to chef API.  Bailing out")
            raise err
        end
    end
else

    tries = 3
    begin
        nodes1 = search(:node, "(domain:prod* OR domain:v* OR domain:ops*) AND app_environment:production* AND ec2_region:#{region} AND tealium_use_nagios:true")
    rescue Net::HTTPServerException => err
        Chef::Log.info("Search for all roles failed with: #{err}")
        tries -= 1
        if tries > 0
            Chef::Log.info("Retrying")
            retry
        else
            Chef::Log.error("Tried a few times and we keep getting exceptions talking to chef API.  Bailing out")
            raise err
        end
    end



    tries = 3
    begin
        nagiosnodes = search(:node, "domain:prod* AND role:nagios NOT ec2_instance_id:#{node['ec2']['instance_id']}")
    rescue Net::HTTPServerException => err
        Chef::Log.info("Search for all roles failed with: #{err}")
        tries -= 1
        if tries > 0
            Chef::Log.info("Retrying")
            retry
        else
            Chef::Log.error("Tried a few times and we keep getting exceptions talking to chef API.  Bailing out")
            raise err
        end
    end
  
    Chef::Log.warn("Nagios Nodes are #{nagiosnodes}.")
  
    nodes = []
    nodes1 = nodes1.concat(nagiosnodes)
    nodes1.each do |n|
        if n.roles.include?("base")
            nodes << n
        end
    end
end

if domain.match(/^privatecloud\d/) or domain.match(/^pc\d/)
    #nodes = search(:node, "app_environment:#{node['app_environment']} AND domain:#{node['domain']}")
    nodes = search(:node, "app_environment:#{node['app_environment']}")
end

if nodes.empty?
    Chef::Log.warn("No nodes returned from search, using this node so hosts.cfg has data")
    nodes = Array.new
    nodes << node
end

# find all unique platforms to create hostgroups
os_list = Array.new

nodes.each do |n|
    if !os_list.include?(n['os'])
        os_list << n['os']
    end
end

# Load Nagios services from the nagios_services data bag
tries = 3
begin
  services = search(:nagios_services, '*:*')
rescue Net::HTTPServerException => err
    Chef::Log.info("Search for all roles failed with: #{err}")
    tries -= 1
    if tries > 0
        Chef::Log.info("Retrying")
        retry
    else
        Chef::Log.info("Could not search for nagios_service data bag items, skipping dynamically generated service checks")
    end
end


if services.nil? || services.empty?
  Chef::Log.info("No services returned from data bag search.")
  services = Array.new
end

# Load search defined Nagios hostgroups from the nagios_hostgroups data bag and find nodes
tries = 3
begin
    hostgroup_nodes= Hash.new
    hostgroup_list = Array.new
    search(:nagios_hostgroups, '*:*') do |hg|
        hostgroup_list << hg['hostgroup_name']
        temp_hostgroup_array= Array.new
        search(:node, "#{hg['search_query']}") do |n|
            temp_hostgroup_array << n['hostname']
        end
        hostgroup_nodes[hg['hostgroup_name']] = temp_hostgroup_array.join(",")
    end
rescue Net::HTTPServerException
    tries -= 1
    if tries > 0
        Chef::Log.info("Retrying")
        retry
    else
        Chef::Log.info("Search for nagios_hostgroups data bag failed, so we'll just move on.")
    end
end

members = Array.new

unless node['instance_role'] == 'vagrant'
  sysadmins.each do |s|
    members << s['id']
  end
else
  members << "nagiosadmin"
end

# maps nodes into nagios hostgroups
role_list = Array.new
service_hosts = Hash.new
tries = 3
begin
    search(:role, "*:*") do |r|
        role_list << r.name
        triesA = 3
        begin
            search(:node, "role:#{r.name} AND app_environment:#{node[:app_environment]}") do |n|
                service_hosts[r.name] = n['hostname']
            end
        rescue Net::HTTPServerException => errr
            Chef::Log.info("Search for hosts in role #{r.name} with app env #{node[:app_environment]} failed with: #{errr}")
            triesA -= 1
            if triesA > 0
                Chef::Log.info("Retrying #{triesA} more times")
                retry
            else
                Chef::Log.error("Tried a few times and we keep getting exceptions talking to chef API.  Bailing out")
                raise "no_retry"
            end
        end
    end
rescue Net::HTTPServerException => err
    Chef::Log.info("Search for all roles failed with: #{err}")
    tries -= 1
    if tries > 0
        Chef::Log.info("Retrying")
        retry
    else
        Chef::Log.error("Tried a few times and we keep getting exceptions talking to chef API.  Bailing out")
        raise err
    end
rescue StandardError => err
    Chef::Log.info("while searching for all hosts in all roles in this app_environment, search failed with: #{err}")
    raise err
end

if node['public_domain']
    public_domain = node['public_domain']
else
    public_domain = node['domain']
end


nagios_conf "nagios" do
    config_subdir false
end

directory "#{node['nagios']['conf_dir']}/dist" do
    owner node['nagios']['user']
    group node['nagios']['group']
    mode 00755
end

directory node['nagios']['state_dir'] do
    owner node['nagios']['user']
    group node['nagios']['group']
    mode 00751
end

directory "#{node['nagios']['state_dir']}/rw" do
    owner node['nagios']['user']
    group web_group
    mode 02710
end

execute "archive-default-nagios-object-definitions" do
    command "mv #{node['nagios']['config_dir']}/*_nagios*.cfg #{node['nagios']['conf_dir']}/dist"
    not_if { Dir.glob("#{node['nagios']['config_dir']}/*_nagios*.cfg").empty? }
    end

directory "#{node['nagios']['conf_dir']}/certificates" do
    owner web_user
    group web_group
    mode 00700
end

bash "Create SSL Certificates" do
    cwd "#{node['nagios']['conf_dir']}/certificates"
    code <<-EOH
    umask 077
    openssl genrsa 2048 > nagios-server.key
    openssl req -subj "#{node['nagios']['ssl_req']}" -new -x509 -nodes -sha1 -days 3650 -key nagios-server.key > nagios-server.crt
    cat nagios-server.key nagios-server.crt > nagios-server.pem
    EOH
    not_if { ::File.exists?("#{node['nagios']['conf_dir']}/certificates/nagios-server.pem") }
end

%w{ nagios cgi }.each do |conf|
    nagios_conf conf do
        config_subdir false
    end
end

%w{ templates timeperiods}.each do |conf|
    nagios_conf conf
end

domain = node[:domain]

# this will probably need adjustment for privatecloud
case domain
when "prod1.us-w1.int.ops.tlium.com"
    url = "us-west-1-vpc.nagios.ops.tlium.com/nagios3/"
when "prod1.us-e1.int.ops.tlium.com"
    url = "us-east-1-vpc.nagios.ops.tlium.com/nagios3/"
when "prod1.eu-w1.int.ops.tlium.com"
    url = "eu-west-1-vpc.nagios.ops.tlium.com/nagios3/"
when "prod1.eu-c1.int.ops.tlium.com"
    url = "eu-central-1-vpc.nagios.ops.tlium.com/nagios3/"
when "us-west-1.compute.internal"
    url = "us-west-1.nagios.ops.tlium.com/nagios3/"
when "eu-w1"
    url = "eu-west-1.nagios.ops.tlium.com/nagios3/"
when "ec2.internal"
    url = "us-east-1.nagios.ops.tlium.com/nagios3/"
end

app_environment = node["app_environment"] || "development"
rabbitmq_db = search(:rabbitmq_users,"id:production_vpc1").first
adminpass = rabbitmq_db["users"]["admin"]["password"]

nagios_conf "commands" do
    variables(
        :services => services,
        :url => url,
        :adminpass => adminpass
    )
end

if node[:monitored_region].nil?
    uconnects = []
else
    uconnects = []
    tries = 3
    begin
        # these search terms will definitely need ajustment for private cloud
        search = search(:node, "domain:prod* AND app_environment:production* AND placement_availability_zone:#{region}*")
        search.each do |n|
            if n.recipes.include?("uconnect::s2s_logger_plenv") || n.recipes.include?("uconnect")
                uconnects << n
            end
        end
    rescue Net::HTTPServerException => err
        Chef::Log.info("Search for prod nodes failed with: #{err}")
        tries -= 1
        if tries > 0
            Chef::Log.info("Retrying")
            retry
        else
            Chef::Log.error("Tried a few times and we keep getting exceptions talking to chef API.  Bailing out")
            raise err
        end
    end
end

Chef::Log.warn("Uconnects are: #{uconnects}")

designation = "host_name"

Chef::Log.warn("First App_Environment is: #{node[:app_environment]}")

au_east = search(:node, "chef_environment:production AND role:dc_amazon_uploader AND ec2_region:us-east-1")
au_eu_west = search(:node, "chef_environment:production AND role:dc_amazon_uploader AND ec2_region:eu-west-1")
au_eu_central = search(:node, "chef_environment:production AND role:dc_amazon_uploader AND ec2_region:eu-central-1")

esp_us_east = search(:node, "chef_environment:production AND role:eventstream_processor AND ec2_region:us-east-1")
esp_us_west = search(:node, "chef_environment:production AND role:eventstream_processor AND ec2_region:us-west-1")
esp_eu_west = search(:node, "chef_environment:production AND role:eventstream_processor AND ec2_region:eu-west-1")
esp_eu_central = search(:node, "chef_environment:production AND role:eventstream_processor AND ec2_region:eu-central-1")

dd_us_east = search(:node, "chef_environment:production AND role:dc_data_distributor AND ec2_region:us-east-1")
dd_us_west = search(:node, "chef_environment:production AND role:dc_data_distributor AND ec2_region:us-west-1")
dd_eu_west = search(:node, "chef_environment:production AND role:dc_data_distributor AND ec2_region:eu-west-1")
dd_eu_central = search(:node, "chef_environment:production AND role:dc_data_distributor AND ec2_region:eu-central-1")

Chef::Log.warn("**************************** East AUs are: #{au_east} ************************************")
Chef::Log.warn("**************************** EU West AUs are: #{au_eu_west} ************************************")
Chef::Log.warn("**************************** EU Central AUs are: #{au_eu_central} ************************************")

au_east_id = []
au_east.each do |n|
  Chef::Log.warn("**************************** This AU: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  au_east_id << n[:ec2][:instance_id]
end

au_eu_west_id = []
au_eu_west.each do |n|
  Chef::Log.warn("**************************** This AU: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  au_eu_west_id << n[:ec2][:instance_id]
end

au_eu_central_id = []
au_eu_central.each do |n|
  Chef::Log.warn("**************************** This AU: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  au_eu_central_id << n[:ec2][:instance_id]
end

esp_us_east_id = []
esp_us_east.each do |n|
  Chef::Log.warn("**************************** This ESP: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  esp_us_east_id << n[:ec2][:instance_id]
end

esp_us_west_id = []
esp_us_west.each do |n|
  Chef::Log.warn("**************************** This ESP: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  esp_us_west_id << n[:ec2][:instance_id]
end

esp_eu_west_id = []
esp_eu_west.each do |n|
  Chef::Log.warn("**************************** This ESP: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  esp_eu_west_id << n[:ec2][:instance_id]
end

esp_eu_central_id = []
esp_eu_central.each do |n|
  Chef::Log.warn("**************************** This ESP: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  esp_eu_central_id << n[:ec2][:instance_id]
end

dd_us_east_id = []
dd_us_east.each do |n|
  Chef::Log.warn("**************************** This D: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  dd_us_east_id << n[:ec2][:instance_id]
end

dd_us_west_id = []
dd_us_west.each do |n|
  Chef::Log.warn("**************************** This DD: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  dd_us_west_id << n[:ec2][:instance_id]
end

dd_eu_west_id = []
dd_eu_west.each do |n|
  Chef::Log.warn("**************************** This DD: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  dd_eu_west_id << n[:ec2][:instance_id]
end

dd_eu_central_id = []
dd_eu_central.each do |n|
  Chef::Log.warn("**************************** This DD: #{n} has instance ID : #{n[:ec2][:instance_id]} ***********************************")
  dd_eu_central_id << n[:ec2][:instance_id]
end

Chef::Log.warn("**************************** East AU Instance ID array is: #{au_east_id} ************************************")
Chef::Log.warn("**************************** EU West AU Instance ID array is: #{au_eu_west_id} ************************************")
Chef::Log.warn("**************************** EU Central AU Instance ID array is: #{au_eu_central_id} ************************************")

if node[:ec2][:local_ipv4] == "10.1.2.7" or node[:app_environment].match(/^privatecloud\d/)
ip = "#{node['hostname']} - #{node[:ipaddress]}"
environment = "#{node[:app_environment]}"

Chef::Log.warn("Nagios IP is: #{ip}")
Chef::Log.warn("Second App_Environment is: #{environment}")

  template "/home/ubuntu/nagios" do
    source "nagios.sudoers.erb"
    owner "root"
    group "root"
    mode 0440
  end

  if ::File.exists?('/home/ubuntu/nagios')
    FileUtils.cp('/home/ubuntu/nagios', '/etc/sudoers.d/nagios')
  end  

  nagios_conf "services" do
    variables(
      :service_hosts => service_hosts,
      :services => services,
      :ip => ip,
      :environment => environment,
      :designation => designation,
      :uconnects => uconnects,
      :au_east_id => au_east_id,
      :au_eu_west_id => au_eu_west_id,
      :au_eu_central_id =>au_eu_central_id,
      :esp_us_east_id => esp_us_east_id,
      :esp_us_west_id => esp_us_west_id,
      :esp_eu_west_id => esp_eu_west_id,
      :esp_eu_central_id => esp_eu_central_id,
      :dd_us_east_id => dd_us_east_id,
      :dd_us_west_id => dd_us_west_id,
      :dd_eu_west_id => dd_eu_west_id,
      :dd_eu_central_id => dd_eu_central_id
    )
  end
else
  nagios_conf "services" do
    variables(
      :service_hosts => service_hosts,
      :services => services,
      :uconnects => uconnects,
      :designation => designation,
      :region => region
    )
  end
end

nagios_conf "contacts" do
 variables :admins => sysadmins, :members => members
end

nagios_conf "hostgroups" do
  variables(
    :roles => role_list,
    :os => os_list,
    :search_hostgroups => hostgroup_list,
    :search_nodes => hostgroup_nodes
    )
end

nagios_conf "hosts" do
  variables( 
  :nodes => nodes
  )
end

include_recipe "nagios::pagerduty"

service "nagios" do
  service_name node['nagios']['server']['service_name']
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

# Add the NRPE check to monitor the Nagios server
nagios_nrpecheck "check_nagios" do
  command "#{node['nagios']['plugin_dir']}/check_nagios"
  parameters "-F #{node["nagios"]["cache_dir"]}/status.dat -e 4 -C /usr/sbin/#{node['nagios']['server']['service_name']}"
  action :add
end
