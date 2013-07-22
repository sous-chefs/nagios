#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Author:: Tim Smith <tsmith84@gmail.com>
# Cookbook Name:: nagios
# Recipe:: client_package
#
# Copyright 2013, Opscode, Inc
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

# nrpe packages are available in EPEL on rhel / fedora platforms
# fedora 17 and later don't require epel
if platform_family?("rhel","fedora")
  unless platform?("fedora") && node['platform_version'] < 17
    include_recipe "yum::epel"
  end
end

# install the nrpe packages specified in the ['nrpe']['packages'] attribute
node['nagios']['nrpe']['packages'].each do |pkg|
  package pkg
end
