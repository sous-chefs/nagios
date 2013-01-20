#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: server_package
#
# Copyright 2011, Opscode, Inc
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
#

if node['platform_family'] == 'debian'

  # Nagios package requires to enter the admin password
  # We generate it randomly as it's overwritten later in the config templates
  random_initial_password = rand(36**16).to_s(36)

  %w{adminpassword adminpassword-repeat}.each do |setting|
    execute "preseed nagiosadmin password" do
      command "echo #{node['nagios']['basename']}-cgi #{node['nagios']['basename']}/#{setting} password #{random_initial_password} | debconf-set-selections"
      not_if "dpkg -l #{node['nagios']['basename']}"
    end
  end
end

if node['nagios']['server']['engine'] == 'icinga'
  case node['platform']
  when 'ubuntu'
    apt_repository "icinga_ppa" do
      uri "http://ppa.launchpad.net/formorer/icinga/ubuntu"
      distribution node['lsb']['codename']
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "36862847"
      deb_src true
    end

  when 'debian'
    apt_repository 'backports' do
      uri 'http://backports.debian.org/debian-backports'
      distribution 'squeeze-backports'
      components ['main']
      only_if { node['lsb']['codename'] == 'squeeze' }
    end

    apt_repository "debmon" do
      uri 'http://debmon.org/debmon'
      distribution "debmon-#{node['lsb']['codename']}"
      components ['main']
      key 'http://debmon.org/debmon/repo.key'
    end

  else
    raise "Platform #{node['platform']} doesn't support Icinga packages yet."

  end
end

package node['nagios']['basename']
package 'nagios-images'
package 'nagios-nrpe-plugin' do
  # Debian/Ubuntu nagios-nrpe-plugin package recommends nagios3
  # package, and at least some base systems follow recommendations
  # automatically. In effect, if we want to use Icinga, we end up with
  # both Icinga and an unconfigured Nagios. We want to prevent Apt
  # from doing that.
  options '--no-install-recommends' if node['platform_family'] == 'debian'
end

include_recipe "nagios::client"
