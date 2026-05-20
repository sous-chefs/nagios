# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Nagios object resources' do
  {
    nagios_command: ['check_test', { 'command_line' => '$USER1$/check_test' }],
    nagios_contact: ['admin', { 'alias' => 'Admin', 'email' => 'admin@example.com' }],
    nagios_contactgroup: ['admins', { 'alias' => 'Admins' }],
    nagios_host: ['host1', { 'address' => '127.0.0.1' }],
    nagios_hostdependency: ['host1', { 'dependent_host_name' => 'host2' }],
    nagios_hostescalation: ['host1', { 'first_notification' => 1, 'last_notification' => 2 }],
    nagios_hostgroup: ['linux', { 'alias' => 'Linux' }],
    nagios_resource: ['USER1', { 'value' => '/usr/lib/nagios/plugins' }],
    nagios_service: ['load', { 'check_command' => 'check_load', 'host_name' => 'host1' }],
    nagios_servicedependency: ['load', { 'dependent_service_description' => 'ping' }],
    nagios_serviceescalation: ['load', { 'first_notification' => 1, 'last_notification' => 2 }],
    nagios_servicegroup: ['base', { 'alias' => 'Base Services' }],
    nagios_timeperiod: ['24x7', { 'alias' => 'Always', 'times' => { 'monday' => '00:00-24:00' } }],
  }.each do |resource_name, (object_name, options)|
    describe resource_name.to_s do
      step_into resource_name
      platform 'ubuntu', '24.04'

      recipe do
        send(resource_name, object_name) do
          options options
        end
      end

      it 'converges the object resource' do
        matcher = send("create_#{resource_name}", object_name)
        expect(chef_run).to matcher
      end
    end
  end
end
