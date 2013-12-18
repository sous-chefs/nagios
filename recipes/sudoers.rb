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

if node.roles.include?("uconnect_logger") || node.roles.include?("hostname_uconnect")
  template "/tmp/uconnect" do
    source "uconnect.sudoers.erb"
    owner "root"
    group "root"
    mode 0440
  end

  if ::File.exists?('/tmp/uconnect')
    FileUtils.cp('/tmp/uconnect', '/etc/sudoers.d/uconnect')
  end
end

if node.roles.include?("hostname_eventstream")
  template "/tmp/eventstream" do
    source "eventstream.sudoers.erb"
    owner "root"
    group "root"
    mode 0440
  end

  if ::File.exists?('/tmp/eventstream')
    FileUtils.cp('/tmp/eventstream', '/etc/sudoers.d/eventstream')
  end
end

if node.roles.include?("rabbitmq_server")
  template "/tmp/rabbitmq" do
    source "rabbitmq.sudoers.erb"
    owner "root"
    group "root"
    mode 0440
  end

  if ::File.exists?('/tmp/rabbitmq')
    FileUtils.cp('/tmp/rabbitmq', '/etc/sudoers.d/rabbitmq')
  end
end

if node.roles.include?("utui")
  template "/home/ubuntu/utui" do
    source "utui.sudoers.erb"
    owner "root"
    group "root"
    mode 0440
  end

  if ::File.exists?('/home/ubuntu/utui')
    FileUtils.cp('/home/ubuntu/utui', '/etc/sudoers.d/utui')
  end
end
