#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Attributes:: default
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

# Allow a Nagios server to monitor hosts in multiple environments.  Impacts NRPE configs as well
default['nagios']['multi_environment_monitoring'] = false

# If set allows specifying an interface name to use for client monitoring
# (i.e. bond.2001 for ipaddress_bond.2001)  Requires ohai netaddr plugin
# or will fall back to node["ipaddress"].
default['nagios']['server']['monitored_client_interface'] = nil

default['nagios']['user']  = 'nagios'
default['nagios']['group'] = 'nagios'

case node['platform_family']
when 'debian'
default['nagios']['plugin_dir']     = '/usr/lib/nagios/plugins'
when 'rhel','fedora'
  if node['kernel']['machine'] == "i686"
    default['nagios']['plugin_dir'] = '/usr/lib/nagios/plugins'
  else
    default['nagios']['plugin_dir'] = '/usr/lib64/nagios/plugins'
  end
else
  default['nagios']['plugin_dir']   = '/usr/lib/nagios/plugins'
end
