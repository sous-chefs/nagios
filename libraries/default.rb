#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Tim Smith <tim@cozy.co>
# Cookbook Name:: nagios
# Library:: default
#
# Copyright 2009, 37signals
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
def nagios_boolean(true_or_false)
  true_or_false ? '1' : '0'
end

def nagios_interval(seconds)
  if seconds.to_i != 0 && seconds.to_i < node['nagios']['interval_length'].to_i
    fail ArgumentError, "Specified nagios interval of #{seconds} seconds must ether be zero or be equal to or greater than the default interval length of #{node['nagios']['interval_length']}"
  end
  interval = seconds.to_f / node['nagios']['interval_length']
  if interval != interval.to_i
    fail ArgumentError, "Specified nagios interval of #{seconds} seconds must be a multiple of the interval length of #{node['nagios']['interval_length']}"
  end
  interval
end

def nagios_attr(name)
  node['nagios'][name]
end

# decide whether to use internal or external IP addresses for this node
# if the nagios server is not in the cloud, always use public IP addresses for cloud nodes.
# if the nagios server is in the cloud, use private IP addresses for any
#   cloud servers in the same cloud, public IPs for servers in other clouds
#   (where other is defined by node['cloud']['provider'])
# if the cloud IP is nil then use the standard IP address attribute.  This is a work around
#   for OHAI incorrectly identifying systems on Cisco hardware as being in Rackspace
def ip_to_monitor(monitored_host, server_host = node)
  # if interface to monitor is specified implicitly use that
  if node['nagios']['monitoring_interface'] && node['network']["ipaddress_#{node['nagios']['monitoring_interface']}"]
    node['network']["ipaddress_#{node['nagios']['monitoring_interface']}"]
  # if server is not in the cloud and the monitored host is
  elsif server_host['cloud'].nil? && monitored_host['cloud']
    monitored_host['cloud']['public_ipv4'].include?('.') ? monitored_host['cloud']['public_ipv4'] : monitored_host['ipaddress']
  # if server host is in the cloud and the monitored node is as well, but they are not on the same provider
  elsif server_host['cloud'] && monitored_host['cloud'] && monitored_host['cloud']['provider'] != server_host['cloud']['provider']
    monitored_host['cloud']['public_ipv4'].include?('.') ? monitored_host['cloud']['public_ipv4'] : monitored_host['ipaddress']
  else
    monitored_host['ipaddress']
  end
end
