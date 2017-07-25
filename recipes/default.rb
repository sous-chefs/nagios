#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@chef.io>
# Author:: Nathan Haneysmith <nathan@chef.io>
# Author:: Seth Chisamore <schisamo@chef.io>
# Author:: Tim Smith <tsmith@chef.io>
# Cookbook:: nagios
# Recipe:: default
#
# Copyright 2009, 37signals
# Copyright 2009-2016, Chef Software, Inc.
# Copyright 2013-2014, Limelight Networks, Inc.
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

# configure either Apache2 or NGINX
case node['nagios']['server']['web_server']
when 'nginx'
  Chef::Log.info 'Setting up Nagios server via NGINX'
  include_recipe 'nagios::nginx'
when 'apache'
  Chef::Log.info 'Setting up Nagios server via Apache2'
  include_recipe 'nagios::apache'
when 'none'
  Chef::Log.info 'Setting up Nagios server without web server'
  include_recipe 'nagios::server'
else
  Chef::Log.fatal('Unknown web server option provided for Nagios server: ' \
                  "#{node['nagios']['server']['web_server']} provided. Allowed:" \
                  "'nginx', 'apache', or 'none'")
end
