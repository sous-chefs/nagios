#
# Author:: Jack Jacobs <devops@tealium.com>
# Cookbook Name:: nagios
# Recipe:: sudoers
#
# Copyright 2013, Tealium Inc.
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

if node.roles.include?("hostname_eventstream")
  sudo "nagios" do
    user "nagios"
    runas "ALL"
    commands ["/usr/lib/nagios/plugins/check_log3_passive.pl"]
    host "ALL"
    nopasswd true
  end
end

if node.roles.include?("rabbitmq_server")
  sudo "nagios" do
    user "nagios"
    runas "ALL"
    commands ["/usr/lib/nagios/plugins/check_rabbitmq_unackd.py"]
    host "ALL"
    nopasswd true
  end
end

if node.roles.include?("utui")
  sudo "nagios" do
    user "nagios"
    runas "ALL"
    commands ["/usr/lib/nagios/plugins/check_log3_passive.pl"]
    host "ALL"
    nopasswd true
  end
end
