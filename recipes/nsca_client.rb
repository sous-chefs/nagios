#
# Author:: Jack Jacobs <devops@tealium.com>
# Cookbook Name:: nagios
# Recipe:: nsca_client
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

template "#{node['nagios']['nrpe']['conf_dir']}/send_nsca.cfg" do
    source "send_nsca.cfg.erb"
    owner node['nagios']['user']
    group node['nagios']['group']
    mode 0644
end

# Upstart 
#template "/etc/init/nsca.conf" do
#  action :create
#  source "upstart.erb"
#  group "root"
#  owner "root"
#  mode 0644
#  notifies :start, "service[nsca]"
#end
#
# service
#service "nsca" do
#  provider Chef::Provider::Service::Upstart
#  supports :status => true, :start => true
#  action :start
#end
