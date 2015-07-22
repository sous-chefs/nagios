#
# Author:: Jake Vanderdray <jvanderdray@customink.com>
# Cookbook Name:: nagios
# Recipe:: pagerduty
#
# Copyright 2011, CustomInk LLC
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

package "libwww-perl" do
  case node["platform"]
  when "redhat", "centos", "scientific", "fedora", "suse", "amazon"
    package_name "perl-libwww-perl"
  when "debian","ubuntu"
    package_name "libwww-perl"
  when "arch"
    package_name "libwww-perl"
  end
  action :install
end

package "libcrypt-ssleay-perl" do
  case node["platform"]
  when "redhat", "centos", "scientific", "fedora", "suse", "amazon"
    package_name "perl-Crypt-SSLeay"
  when "debian","ubuntu"
    package_name "libcrypt-ssleay-perl"
  when "arch"
    package_name "libcrypt-ssleay-perl"
  end
  action :install
end

# need to support 
#   multi-region VPC and non VPC for our not fully VPC prod env
#   multi-region VPC for private clouds (currently single region, but could become multi sometime)

api_key = ''
if node['instance_role'] == 'vagrant'
    api_key = "test"
else
    # we really only want to do this for prod
    region = node['ec2']['region']

    # if its private only, its VPC so tack that on
    unless node['cloud']['public_ipv4'].nil?
        region = "#{region}-nonvpc"
    end

    key_bag = data_bag_item('pager_duty', node['app_environment'])
    api_key = key_bag['keys'][region]
end

template "/etc/nagios3/conf.d/pagerduty_nagios.cfg" do
  owner "nagios"
  group "nagios"
  mode 0644
  source "pagerduty_nagios.cfg.erb"
  variables :api_key => api_key
end

remote_file "#{node['nagios']['plugin_dir']}/pagerduty_nagios.pl" do
  owner "root"
  group "root"
  mode 0755
  source "https://raw.github.com/PagerDuty/pagerduty-nagios-pl/master/pagerduty_nagios.pl"
  action :create_if_missing
end

cron "Flush Pagerduty" do
  user "nagios"
  command "#{node['nagios']['plugin_dir']}/pagerduty_nagios.pl flush"
  minute "*"
  hour "*"
  day "*"
  month "*"
  weekday "*"
  action :create
end
