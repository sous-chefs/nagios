#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: service
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
#

require_relative 'base'

class Nagios
  #
  #  This class holds all methods with regard to servicedependency options,
  #  that are used within nagios configurations.
  #
  class Service < Nagios::Base
    attr_reader   :service_description,
                  :host_name,
                  :hostgroup_name,
                  :contacts,
                  :contact_groups,
                  :check_command,
                  :servicegroups,
                  :hostgroups,
                  :custom_options

    attr_accessor :display_name,
                  :is_volatile,
                  :initial_state,
                  :max_check_attempts,
                  :check_interval,
                  :retry_interval,
                  :active_checks_enabled,
                  :passive_checks_enabled,
                  :check_period,
                  :obsess_over_service,
                  :check_freshness,
                  :freshness_threshold,
                  :event_handler,
                  :event_handler_enabled,
                  :low_flap_threshold,
                  :high_flap_threshold,
                  :flap_detection_enabled,
                  :flap_detection_options,
                  :process_perf_data,
                  :retain_status_information,
                  :retain_nonstatus_information,
                  :notification_interval,
                  :first_notification_delay,
                  :notification_period,
                  :notification_options,
                  :notifications_enabled,
                  :parallelize_check,
                  :stalking_options,
                  :notes,
                  :notes_url,
                  :action_url,
                  :icon_image,
                  :icon_image_alt

    def initialize(service_description)
      @service_description = service_description
      srv = service_description.split('!')
      @check_command       = srv.shift
      @arguments           = srv
      @servicegroups       = {}
      @contacts            = {}
      @contact_groups      = {}
      @hostgroups          = {}
      @hosts               = {}
      @custom_options      = {}
      super()
    end
    # rubocop:enable MethodLength

    def check_command
      if blank?(@arguments)
        @check_command.to_s
      else
        @check_command.to_s + '!' + @arguments.join('!')
      end
    end

    def check_command=(cmd)
      cmd = cmd.split('!')
      cmd.shift
      @arguments = cmd
    end

    def check_period
      get_timeperiod(@check_period)
    end

    # contacts
    # This is a list of the short names of the contacts that should be notified
    # whenever there are problems (or recoveries) with this host.
    # Multiple contacts should be separated by commas.
    # Useful if you want notifications to go to just a few people and don't want
    # to configure contact groups.
    # You must specify at least one contact or contact group in each host definition.
    def contacts_list
      @contacts.values.map(&:to_s).sort.join(',')
    end

    # contact_groups
    # This is a list of the short names of the contact groups that should be notified
    # whenever there are problems (or recoveries) with this host.
    # Multiple contact groups should be separated by commas.
    # You must specify at least one contact or contact group in each host definition.
    def contact_groups_list
      @contact_groups.values.map(&:to_s).sort.join(',')
    end

    def definition
      if blank?(hostgroup_name_list) && blank?(host_name_list) && name.nil?
        "# Skipping #{service_description} because host_name and hostgroup_name are missing."
      else
        configured = configured_options
        custom_options.each { |_, v| configured[v.to_s] = v.value }
        get_definition(configured, 'service')
      end
    end

    # host_name
    # This directive is used to return all host objects
    def host_name
      @hosts
    end

    # host_name_list
    # This directive is used to specify the short name(s) of the host(s) that the service
    # "runs" on or is associated with. Multiple hosts should be separated by commas.
    def host_name_list
      @hosts.values.map(&:to_s).sort.join(',')
    end

    # hostgroup_name
    # This directive is used to return all hostgroup objects
    def hostgroup_name
      @hostgroups
    end

    # hostgroup_name_list
    # This directive is used to specify the short name(s) of the hostgroup(s) that the
    # service "runs" on or is associated with. Multiple hostgroups should be separated by commas.
    # The hostgroup_name may be used instead of, or in addition to, the host_name directive.
    def hostgroup_name_list
      @hostgroups.values.map(&:to_s).sort.join(',')
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'contacts', Nagios::Contact)
      update_members(hash, 'contact_groups', Nagios::Contactgroup)
      update_members(hash, 'host_name', Nagios::Host)
      update_members(hash, 'hostgroup_name', Nagios::Hostgroup)
      update_members(hash, 'servicegroups', Nagios::Servicegroup, true)
      update_members(hash, 'check_command', Nagios::Command)
    end

    def notification_period
      get_timeperiod(@notification_period)
    end

    def push(obj)
      case obj
      when Nagios::Servicegroup
        push_object(obj, @servicegroups)
      when Nagios::Hostgroup
        push_object(obj, @hostgroups)
      when Nagios::Host
        push_object(obj, @hosts)
      when Nagios::Contact
        push_object(obj, @contacts)
      when Nagios::Contactgroup
        push_object(obj, @contact_groups)
      when Nagios::Command
        @check_command = obj
      when Nagios::Timeperiod
        @check_period = obj
        @notification_period = obj
      when Nagios::CustomOption
        push_object(obj, @custom_options)
      end
    end

    def pop(obj)
      return if obj == self
      case obj
      when Nagios::Servicegroup
        if @servicegroups.keys?(obj.to_s)
          pop_object(obj, @servicegroups)
          pop(self, obj)
        end
      when Nagios::Hostgroup
        if @hostgroups.keys?(obj.to_s)
          pop_object(obj, @hostgroups)
          pop(self, obj)
        end
      when Nagios::Host
        if @hosts.keys?(obj.to_s)
          pop_object(obj, @hosts)
          pop(self, obj)
        end
      when Nagios::Contact
        if @contacts.keys?(obj.to_s)
          pop_object(obj, @contacts)
          pop(self, obj)
        end
      when Nagios::Contactgroup
        if @contact_groups.keys?(obj.to_s)
          pop_object(obj, @contact_groups)
          pop(self, obj)
        end
      when Nagios::Command
        @check_command = nil if @check_command == obj
      when Nagios::Timeperiod
        @check_period = nil if @check_command == obj
        @notification_period = nil if @check_command == obj
      when Nagios::CustomOption
        if @custom_options.keys?(obj.to_s)
          pop_object(obj, @custom_options)
          pop(self, obj)
        end
      end
    end
    # rubocop:enable MethodLength

    # servicegroups
    # This directive is used to define the description of the service, which may contain spaces,
    # dashes, and colons (semicolons, apostrophes, and quotation marks should be avoided).
    # No two services associated with the same host can have the same description.
    # Services are uniquely identified with their host_name and service_description directives.
    def servicegroups_list
      @servicegroups.values.map(&:to_s).sort.join(',')
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Service.new(name))
    end

    def to_s
      service_description
    end

    # check the integer options
    # default = nil

    def max_check_attempts=(int)
      @max_check_attempts = check_integer(int)
    end

    def check_interval=(int)
      @check_interval = check_integer(int)
    end

    def retry_interval=(int)
      @retry_interval = check_integer(int)
    end

    def freshness_threshold=(int)
      @freshness_threshold = check_integer(int)
    end

    def low_flap_threshold=(int)
      @low_flap_threshold = check_integer(int)
    end

    def high_flap_threshold=(int)
      @high_flap_threshold = check_integer(int)
    end

    def notification_interval=(int)
      @notification_interval = check_integer(int)
    end

    def first_notification_delay=(int)
      @first_notification_delay = check_integer(int)
    end

    # check the True/False options
    # default = nil

    # rubocop:disable Style/PredicateName
    def is_volatile=(arg)
      @is_volatile = check_bool(arg)
    end
    # rubocop:enable Style/PredicateName

    def active_checks_enabled=(arg)
      @active_checks_enabled = check_bool(arg)
    end

    def passive_checks_enabled=(arg)
      @passive_checks_enabled = check_bool(arg)
    end

    def obsess_over_service=(arg)
      @obsess_over_service = check_bool(arg)
    end

    def check_freshness=(arg)
      @check_freshness = check_bool(arg)
    end

    def event_handler_enabled=(arg)
      @event_handler_enabled = check_bool(arg)
    end

    def flap_detection_enabled=(arg)
      @flap_detection_enabled = check_bool(arg)
    end

    def process_perf_data=(arg)
      @process_perf_data = check_bool(arg)
    end

    def retain_status_information=(arg)
      @retain_status_information = check_bool(arg)
    end

    def retain_nonstatus_information=(arg)
      @retain_nonstatus_information = check_bool(arg)
    end

    def notifications_enabled=(arg)
      @notifications_enabled = check_bool(arg)
    end

    def parallelize_check=(arg)
      @parallelize_check = check_bool(arg)
    end

    # check other options

    # flap_detection_options
    # This directive is used to determine what service states the flap detection logic will use for this service.
    # Valid options are a combination of one or more of the following:
    #   o = OK states,
    #   w = WARNING states,
    #   c = CRITICAL states,
    #   u = UNKNOWN states.

    def flap_detection_options=(arg)
      @flap_detection_options = check_state_options(arg, %w(o w u c), 'flap_detection_options')
    end

    # notification_options
    # This directive is used to determine when notifications for the service should be sent out.
    # Valid options are a combination of one or more of the following:
    #   w = send notifications on a WARNING state,
    #   u = send notifications on an UNKNOWN state,
    #   c = send notifications on a CRITICAL state,
    #   r = send notifications on recoveries (OK state),
    #   f = send notifications when the service starts and stops flapping,
    #   s = send notifications when scheduled downtime starts and ends.
    #
    # If you specify n (none) as an option, no service notifications will be sent out.
    # If you do not specify any notification options, Nagios will assume that you want
    # notifications to be sent out for all possible states.
    #
    # Example: If you specify w,r in this field, notifications will only be sent out when
    # the service goes into a WARNING state and when it recovers from a WARNING state.

    def notification_options=(arg)
      @notification_options = check_state_options(arg, %w(w u c r f s n), 'notification_options')
    end

    # stalking_options
    # This directive determines which service states "stalking" is enabled for.
    # Valid options are a combination of one or more of the following:
    #   o = stalk on OK states,
    #   w = stalk on WARNING states,
    #   u = stalk on UNKNOWN states,
    #   c = stalk on CRITICAL states.
    #
    # More information on state stalking can be found here.

    def stalking_options=(arg)
      @stalking_options = check_state_options(arg, %w(o w u c), 'stalking_options')
    end

    private

    def config_options
      {
        'name'                         => 'name',
        'use'                          => 'use',
        'service_description'          => 'service_description',
        'host_name_list'               => 'host_name',
        'hostgroup_name_list'          => 'hostgroup_name',
        'servicegroups_list'           => 'servicegroups',
        'display_name'                 => 'display_name',
        'is_volatile'                  => 'is_volatile',
        'check_command'                => 'check_command',
        'initial_state'                => 'initial_state',
        'max_check_attempts'           => 'max_check_attempts',
        'check_interval'               => 'check_interval',
        'retry_interval'               => 'retry_interval',
        'active_checks_enabled'        => 'active_checks_enabled',
        'passive_checks_enabled'       => 'passive_checks_enabled',
        'check_period'                 => 'check_period',
        'obsess_over_service'          => 'obsess_over_service',
        'check_freshness'              => 'check_freshness',
        'freshness_threshold'          => 'freshness_threshold',
        'event_handler'                => 'event_handler',
        'event_handler_enabled'        => 'event_handler_enabled',
        'low_flap_threshold'           => 'low_flap_threshold',
        'high_flap_threshold'          => 'high_flap_threshold',
        'flap_detection_enabled'       => 'flap_detection_enabled',
        'flap_detection_options'       => 'flap_detection_options',
        'process_perf_data'            => 'process_perf_data',
        'retain_status_information'    => 'retain_status_information',
        'retain_nonstatus_information' => 'retain_nonstatus_information',
        'notification_interval'        => 'notification_interval',
        'first_notification_delay'     => 'first_notification_delay',
        'notification_period'          => 'notification_period',
        'notification_options'         => 'notification_options',
        'notifications_enabled'        => 'notifications_enabled',
        'parallelize_check'            => 'parallelize_check',
        'contacts_list'                => 'contacts',
        'contact_groups_list'          => 'contact_groups',
        'stalking_options'             => 'stalking_options',
        'notes'                        => 'notes',
        'notes_url'                    => 'notes_url',
        'action_url'                   => 'action_url',
        'icon_image'                   => 'icon_image',
        'icon_image_alt'               => 'icon_image_alt',
        'register'                     => 'register',
      }
    end
    # rubocop:enable MethodLength

    def merge_members(obj)
      obj.contacts.each { |m| push(m) }
      obj.host_name.each { |m| push(m) }
      obj.servicegroups.each { |m| push(m) }
      obj.hostgroup_name.each { |m| push(m) }
      obj.contact_groups.each { |m| push(m) }
      obj.custom_options.each { |_, m| push(m) }
    end
  end
end
