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

case node['platform']
when "ubuntu","debian"
  default['nagios']['client']['install_method'] = 'package'
  default['nagios']['nrpe']['pidfile'] = '/var/run/nagios/nrpe.pid'
when "redhat","centos","fedora","scientific","amazon"
  default['nagios']['client']['install_method'] = 'source'
  default['nagios']['nrpe']['pidfile'] = '/var/run/nrpe.pid'
else
  default['nagios']['client']['install_method'] = 'source'
  default['nagios']['nrpe']['pidfile'] = '/var/run/nrpe.pid'
end

default['nagios']['nrpe']['home']              = "/usr/lib/nagios"
default['nagios']['nrpe']['conf_dir']          = "/etc/nagios"
default['nagios']['nrpe']['dont_blame_nrpe']   = "0"
default['nagios']['nrpe']['command_timeout']   = "60"

# for plugin from source installation
default['nagios']['plugins']['url']      = 'http://prdownloads.sourceforge.net/sourceforge/nagiosplug'
default['nagios']['plugins']['version']  = '1.4.15'
default['nagios']['plugins']['checksum'] = '51136e5210e3664e1351550de3aff4a766d9d9fea9a24d09e37b3428ef96fa5b'

# for nrpe from source installation
default['nagios']['nrpe']['url']      = 'http://prdownloads.sourceforge.net/sourceforge/nagios'
default['nagios']['nrpe']['version']  = '2.12'
default['nagios']['nrpe']['checksum'] = '7e8d093abef7d7ffc7219ad334823bdb612121df40de2dbaec9c6d0adeb04cfc'

default['nagios']['checks']['memory']['critical'] = 10
default['nagios']['checks']['memory']['warning']  = 20
default['nagios']['checks']['load']['critical']   = "30,20,10"
default['nagios']['checks']['load']['warning']    = "15,10,5"
default['nagios']['checks']['smtp_host'] = String.new
default['nagios']['checks']['inode']['critical']  = 15
default['nagios']['checks']['inode']['warning']  = 20

default['nagios']['logfiles']['utui']['log_file'] = "/var/log/syslog"
default['nagios']['logfiles']['sitemap']['log_file'] = "/var/log/syslog"
default['nagios']['logfiles']['dc_uconnect_heap']['log_file'] = "/var/log/tealium/uconnect.log"
default['nagios']['logfiles']['uconnect']['log_file_'] = "/var/log/upstart/s2s-httpd-iron-processor"
default['nagios']['logfiles']['uconnect']['log_file'] = "/var/log/upstart/s2s-httpd-iron-processor.log"
default['nagios']['logfiles']['uconnect']['log_file1'] = "/var/log/upstart/s2s-httpd-iron-processor-1.log"
default['nagios']['logfiles']['uconnect']['log_file2'] = "/var/log/upstart/s2s-httpd-iron-processor-2.log"
default['nagios']['logfiles']['uconnect']['log_file3'] = "/var/log/upstart/s2s-httpd-iron-processor-3.log"
default['nagios']['logfiles']['uconnect']['log_file4'] = "/var/log/upstart/s2s-httpd-iron-processor-4.log"
default['nagios']['logfiles']['uconnect']['log_file5'] = "/var/log/upstart/s2s-httpd-iron-processor-5.log"
default['nagios']['logfiles']['uconnect']['log_file6'] = "/var/log/upstart/s2s-httpd-iron-processor-6.log"
default['nagios']['logfiles']['uconnect']['syslog'] = "/var/log/syslog"
default['nagios']['logfiles']['eventstream']['syslog'] = "/var/log/syslog"
default['nagios']['checks']['utui_login_error']['pattern'] = "ERROR: UNABLE TO LOGIN"
default['nagios']['checks']['utui_publish_error']['pattern'] = "UPLOAD PUBLICATION FAILURE"
default['nagios']['checks']['sitemap_url']['pattern'] = "No sitemap_url found in collection sitemap_urls"

default['nagios']['checks']['sitemap_non_compiled']['pattern'] = "Nothing compiled, yet no errors"

default['nagios']['checks']['utui_publish_insert']['pattern'] = "Could not upsert:"
default['nagios']['checks']['utui_smartFTP_error']['pattern'] = "WARNING: Resetting smartFTP flag"
default['nagios']['checks']['utui_ftp_upload_error']['pattern'] = "FTP UPLOAD FAILURE"
default['nagios']['checks']['rabbit_connection']['pattern'] = "couldn\\'t connect to server"
default['nagios']['checks']['rabbit_auth']['pattern'] = "Connection reset by peer"
default['nagios']['checks']['iron_create']['pattern'] = "Error while creating working directories:"
default['nagios']['checks']['iron_move']['pattern'] = "Could not move"
default['nagios']['checks']['iron_write']['pattern'] = "Unable to write out content"
default['nagios']['checks']['iron_processor_process']['pattern'] = "Unable to process"
default['nagios']['checks']['iron_processor_quarantine']['pattern'] = "Unable to quarantine"
default['nagios']['checks']['dc_uconnect_heap']['pattern'] = "java.lang.OutOfMemoryError: Java heap space"
default['nagios']['checks']['eventstream_logging']['pattern'] = "Error logging request:"

default['nagios']['server_role'] = "nagios"
default['nagios']['multi_environment_monitoring'] = false
