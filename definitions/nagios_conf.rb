#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@getchef.com>
# Author:: Nathan Haneysmith <nathan@getchef.com>
# Author:: Seth Chisamore <schisamo@getchef.com>
# Cookbook Name:: nagios
# Definition:: nagios_conf
#
# Copyright 2009, 37signals
# Copyright 2009-2013, Chef Software, Inc.
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
define :nagios_conf, :variables => {}, :config_subdir => true, :source => nil do
  conf_dir = params[:config_subdir] ? node['nagios']['config_dir'] : node['nagios']['conf_dir']
  params[:source] ||= "#{params[:name]}.cfg.erb"

  template "#{conf_dir}/#{params[:name]}.cfg" do
    owner node['nagios']['user']
    group node['nagios']['group']
    source params[:source]
    mode '0644'
    variables params[:variables]
    notifies :reload, 'service[nagios]'
    backup 0
  end
end
