#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios_test
# Recipe:: default
#
# Copyright (C) 2015 Schuberg Philis.
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

package 'wget'

nagios_command 'system-load' do
  options 'command_line' => '$USER1$/check_load -w $ARG1$ -c $ARG2$'
end

nagios_service 'system-high-load' do
  options 'check_command'  => 'system-load!20,15,10!40,35,30',
          'use'            => 'default-service',
          'hostgroup_name' => 'high_load_servers'
end

nagios_service 'system-medium-load' do
  options 'check_command'  => 'system-load!15,10,5!30,25,20',
          'use'            => 'default-service',
          'hostgroup_name' => 'medium_load_servers'
end

nagios_contact 'sander botman' do
  options 'use'            => 'default-contact',
          'alias'          => 'Nagios Noob',
          'pager'          => '+31651425985',
          'email'          => 'sbotman@schubergphilis.com',
          '_my_custom_key' => 'custom_value'
end

nagios_command 'my-event-handler-command' do
  options 'command_line' => 'ping localhost'
end

nagios_host 'generichosttemplate' do
  options 'use'            => 'server',
          'name'           => 'generichosttemplate',
          'register'       => 0,
          'check_interval' => 10,
          'event_handler'  => 'my-event-handler-command'
end

# bighost1 should have no event_handler, bithost2 should have my-event-handler-command
nagios_host 'bighost1' do
  options 'use'           => 'generichosttemplate',
          'host_name'     => 'bighost1',
          'address'       => '192.168.1.3',
          'event_handler' => 'null'
end

nagios_host 'bighost2' do
  options 'use'            => 'generichosttemplate',
          'host_name'      => 'bighost2',
          'address'        => '192.168.1.4',
          'check_interval' => '20'
end
