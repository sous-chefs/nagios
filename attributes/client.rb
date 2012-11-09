#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Attributes:: client
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
#

case node['platform_family']
when 'debian'
  default['nagios']['client']['install_method'] = 'package'
  default['nagios']['nrpe']['pidfile'] = '/var/run/nagios/nrpe.pid'
when 'rhel','fedora'
  default['nagios']['client']['install_method'] = 'source'
  default['nagios']['nrpe']['pidfile'] = '/var/run/nrpe.pid'
else
  default['nagios']['client']['install_method'] = 'source'
  default['nagios']['nrpe']['pidfile'] = '/var/run/nrpe.pid'
end

default['nagios']['nrpe']['home']              = '/usr/lib/nagios'
default['nagios']['nrpe']['conf_dir']          = '/etc/nagios'
default['nagios']['nrpe']['dont_blame_nrpe']   = 0
default['nagios']['nrpe']['command_timeout']   = 60

# for plugin from source installation
default['nagios']['plugins']['url']      = 'http://prdownloads.sourceforge.net/sourceforge/nagiosplug'
default['nagios']['plugins']['version']  = '1.4.16'
default['nagios']['plugins']['checksum'] = 'b0caf07e0084e9b7f10fdd71cbd3ebabcd85ad78df64da360b51233b0e73b2bd'

# for nrpe from source installation
default['nagios']['nrpe']['url']      = 'http://prdownloads.sourceforge.net/sourceforge/nagios'
default['nagios']['nrpe']['version']  = '2.13'
default['nagios']['nrpe']['checksum'] = 'bac8f7eb9daddf96b732a59ffc5762b1cf073fb70f6881d95216ebcd1254a254'

default['nagios']['checks']['memory']['critical'] = 150
default['nagios']['checks']['memory']['warning']  = 250
default['nagios']['checks']['load']['critical']   = '30,20,10'
default['nagios']['checks']['load']['warning']    = '15,10,5'
default['nagios']['checks']['smtp_host'] = String.new

default['nagios']['server_role'] = 'monitoring'
