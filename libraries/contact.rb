#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: contact
#
# Copyright 2014, Sander Botman
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

require_relative 'base'

class Nagios
  #
  # This class holds all methods with regard to contact options,
  # that are used within nagios configurations.
  #
  class Contact < Nagios::Base
    attr_reader   :contact_name,
                  :contactgroups,
                  :custom_options

    attr_accessor :alias,
                  :host_notifications_enabled,
                  :service_notifications_enabled,
                  :host_notification_period,
                  :service_notification_period,
                  :host_notification_options,
                  :service_notification_options,
                  :host_notification_commands,
                  :service_notification_commands,
                  :email,
                  :pager,
                  :addressx,
                  :can_submit_commands,
                  :retain_status_information,
                  :retain_nonstatus_information

    def initialize(contact_name)
      @contact_name = contact_name
      @contactgroups = {}
      @host_notification_commands = []
      @service_notification_commands = []
      @custom_options = {}
      super()
    end

    def contactgroups_list
      @contactgroups.values.map(&:to_s).sort.join(',')
    end

    def definition
      if email.nil? && name.nil? && pager.nil?
        "# Skipping #{contact_name} because missing email/pager."
      else
        configured = configured_options
        custom_options.each { |_, v| configured[v.to_s] = v.value }
        get_definition(configured, 'contact')
      end
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Contact.new(name))
    end

    def host_notification_commands
      get_commands(@host_notification_commands)
    end

    def host_notification_commands=(obj)
      @host_notification_commands = notification_commands(obj)
    end

    def host_notification_period
      get_timeperiod(@host_notification_period)
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'contactgroups', Nagios::Contactgroup, true)
    end

    def push(obj)
      case obj
      when Nagios::Contactgroup
        push_object(obj, @contactgroups)
      when Nagios::Timeperiod
        @host_notification_period = obj
        @service_notification_period = obj
      when Nagios::CustomOption
        push_object(obj, @custom_options)
      end
    end

    def pop(obj)
      return if obj == self
      case obj
      when Nagios::Contactgroup
        if @contactgroups.keys?(obj.to_s)
          pop_object(obj, @contactgroups)
          pop(self, obj)
        end
      when Nagios::Timeperiod
        @host_notification_period = nil if obj == @host_notification_period
        @service_notification_period = nil if obj == @service_notification_period
      when Nagios::CustomOption
        if @custom_options.keys?(obj.to_s)
          pop_object(obj, @custom_options)
          pop(self, obj)
        end
      end
    end
    # rubocop:enable MethodLength

    def service_notification_commands
      get_commands(@service_notification_commands)
    end

    def service_notification_commands=(obj)
      @service_notification_commands = notification_commands(obj)
    end

    def service_notification_period
      get_timeperiod(@service_notification_period)
    end

    def to_s
      contact_name
    end

    # check the True/False options
    # default = nil
    def host_notifications_enabled=(arg)
      @host_notifications_enabled = check_bool(arg)
    end

    def service_notifications_enabled=(arg)
      @service_notifications_enabled = check_bool(arg)
    end

    def can_submit_commands=(arg)
      @can_submit_commands = check_bool(arg)
    end

    def retain_status_information=(arg)
      @retain_status_information = check_bool(arg)
    end

    def retain_nonstatus_information=(arg)
      @retain_nonstatus_information = check_bool(arg)
    end

    # check other options
    #
    # host_notification_options
    # This directive is used to define the host states for which notifications
    # can be sent out to this contact.
    # Valid options are a combination of one or more of the following:
    #   d = notify on DOWN host states,
    #   u = notify on UNREACHABLE host states,
    #   r = notify on host recoveries (UP states),
    #   f = notify when the host starts and stops flapping,
    #   s = send notifications when host or service scheduled downtime starts and ends.
    #
    # If you specify n (none) as an option, the contact will not receive any type of
    # host notifications.
    def host_notification_options=(arg)
      @host_notification_options = check_state_options(
        arg, %w(d u r f s n), 'host_notification_options')
    end

    # service_notification_options
    # This directive is used to define the service states for which notifications
    # can be sent out to this contact.
    # Valid options are a combination of one or more of the following:
    #   w = notify on WARNING service states,
    #   u = notify on UNKNOWN service states,
    #   c = notify on CRITICAL service states,
    #   r = notify on service recoveries (OK states),
    #   f = notify when the service starts and stops flapping.
    #
    # If you specify n (none) as an option, the contact will not receive any type of
    # service notifications.
    def service_notification_options=(arg)
      @service_notification_options = check_state_options(
        arg, %w(w u c r f n), 'service_notification_options')
    end

    private

    def config_options
      {
        'name'                          => 'name',
        'use'                           => 'use',
        'contact_name'                  => 'contact_name',
        'contactgroups_list'            => 'contactgroups',
        'alias'                         => 'alias',
        'host_notifications_enabled'    => 'host_notifications_enabled',
        'service_notifications_enabled' => 'service_notifications_enabled',
        'host_notification_period'      => 'host_notification_period',
        'service_notification_period'   => 'service_notification_period',
        'host_notification_options'     => 'host_notification_options',
        'service_notification_options'  => 'service_notification_options',
        'host_notification_commands'    => 'host_notification_commands',
        'service_notification_commands' => 'service_notification_commands',
        'email'                         => 'email',
        'pager'                         => 'pager',
        'addressx'                      => 'addressx',
        'can_submit_commands'           => 'can_submit_commands',
        'retain_status_information'     => 'retain_status_information',
        'retain_nonstatus_information'  => 'retain_nonstatus_information',
        'register'                      => 'register',
      }
    end

    def merge_members(obj)
      obj.contactgroups.each { |m| push(m) }
      obj.custom_options.each { |_, m| push(m) }
    end
  end
end
