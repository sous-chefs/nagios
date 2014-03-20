#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Author:: Tim Smith <tsmith@limelight.com>
# Cookbook Name:: nagios
# Attributes:: client
#
# Copyright 2009, 37signals
# Copyright 2009-2013, Opscode, Inc
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
  default['nagios']['client']['install_method']  = 'package'
  default['nagios']['nrpe']['pidfile']           = '/var/run/nagios/nrpe.pid'
  default['nagios']['nrpe']['home']              = '/usr/lib/nagios'
  default['nagios']['nrpe']['packages']          = %w( nagios-nrpe-server nagios-plugins nagios-plugins-basic nagios-plugins-standard )
  if node['kernel']['machine'] == 'i686'
    default['nagios']['nrpe']['ssl_lib_dir']       = '/usr/lib/i386-linux-gnu'
  else
    default['nagios']['nrpe']['ssl_lib_dir']       = '/usr/lib/x86_64-linux-gnu'
  end
  if node['nagios']['client']['install_method'] == 'package'
    default['nagios']['nrpe']['service_name']      = 'nagios-nrpe-server'
  else
    default['nagios']['nrpe']['service_name']      = 'nrpe'
  end
when 'rhel', 'fedora'
  default['nagios']['client']['install_method']  = 'source'
  default['nagios']['nrpe']['pidfile']           = '/var/run/nrpe.pid'
  default['nagios']['nrpe']['packages']          = %w( nrpe nagios-plugins-disk nagios-plugins-load nagios-plugins-procs nagios-plugins-users )
  if node['kernel']['machine'] == 'i686'
    default['nagios']['nrpe']['home']            = '/usr/lib/nagios'
    default['nagios']['nrpe']['ssl_lib_dir']     = '/usr/lib'
  else
    default['nagios']['nrpe']['home']            = '/usr/lib64/nagios'
    default['nagios']['nrpe']['ssl_lib_dir']     = '/usr/lib64'
  end
  default['nagios']['nrpe']['service_name']      = 'nrpe'
else
  default['nagios']['client']['install_method']  = 'source'
  default['nagios']['nrpe']['pidfile']           = '/var/run/nrpe.pid'
  default['nagios']['nrpe']['home']              = '/usr/lib/nagios'
  default['nagios']['nrpe']['ssl_lib_dir']       = '/usr/lib'
  default['nagios']['nrpe']['service_name']      = 'nrpe'
end

default['nagios']['nrpe']['log_facility']       = nil
default['nagios']['nrpe']['debug']              = 0
default['nagios']['nrpe']['conf_dir']           = '/etc/nagios'
default['nagios']['nrpe']['dont_blame_nrpe']    = 0
default['nagios']['nrpe']['command_timeout']    = 60
default['nagios']['nrpe']['connection_timeout'] = nil

# for plugin from source installation
default['nagios']['plugins']['url']      = 'https://www.monitoring-plugins.org/download'
default['nagios']['plugins']['version']  = '1.5'
default['nagios']['plugins']['checksum'] = 'fcc55e23bbf1c70bcf1a90749d30249955d4668a9b776b2521da023c5c2f2170'

# for nrpe from source installation
default['nagios']['nrpe']['url']      = 'http://prdownloads.sourceforge.net/sourceforge/nagios'
default['nagios']['nrpe']['version']  = '2.15'
default['nagios']['nrpe']['checksum'] = '66383b7d367de25ba031d37762d83e2b55de010c573009c6f58270b137131072'

default['nagios']['server_role'] = 'monitoring'
default['nagios']['allowed_hosts'] = nil
default['nagios']['using_solo_search'] = false
