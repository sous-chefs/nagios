#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: host
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
  #  This class holds all methods with regard to host options,
  #  that are used within nagios configurations.
  #
  class Host < Nagios::Base
    attr_reader   :host_name,
                  :parents,
                  :hostgroups,
                  :contacts,
                  :contact_groups,
                  :custom_options

    attr_accessor :alias,
                  :display_name,
                  :address,
                  :check_command,
                  :initial_state,
                  :max_check_attempts,
                  :check_interval,
                  :retry_interval,
                  :active_checks_enabled,
                  :passive_checks_enabled,
                  :check_period,
                  :obsess_over_host,
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
                  :stalking_options,
                  :notes,
                  :notes_url,
                  :action_url,
                  :icon_image,
                  :icon_image_alt,
                  :vrml_image,
                  :statusmap_image,
                  :_2d_coords,
                  :_3d_coords

    def initialize(host_name)
      @host_name = hostname(host_name)
      @hostgroups = {}
      @parents = {}
      @contacts = {}
      @contact_groups = {}
      @check_period = nil
      @notification_period = nil
      @custom_options = {}
      super()
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
      configured = configured_options
      custom_options.each { |_, v| configured[v.to_s] = v.value }
      get_definition(configured, 'host')
    end

    # hostgroups
    # This directive is used to identify the short name(s) of the hostgroup(s)
    # that the host belongs to. Multiple hostgroups should be separated by commas.
    # This directive may be used as an alternative to (or in addition to)
    # using the members directive in hostgroup definitions.
    def hostgroups_list
      @hostgroups.values.map(&:to_s).sort.join(',')
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'parents', Nagios::Host)
      update_members(hash, 'contacts', Nagios::Contact)
      update_members(hash, 'contact_groups', Nagios::Contactgroup)
      update_members(hash, 'hostgroups', Nagios::Hostgroup, true)
    end

    def notification_period
      get_timeperiod(@notification_period)
    end

    def notifications
      @notifications_enabled
    end

    def notifications=(arg)
      @notifications_enabled = check_bool(arg)
    end

    # parents
    # This directive is used to define a comma-delimited list of short names of
    # the "parent" hosts for this particular host. Parent hosts are typically routers,
    # switches, firewalls, etc. that lie between the monitoring host and a remote hosts.
    # A router, switch, etc. which is closest to the remote host is considered
    # to be that host's "parent".
    # If this host is on the same network segment as the host doing the monitoring
    # (without any intermediate routers, etc.) the host is considered to be on the local
    # network and will not have a parent host.
    def parents_list
      @parents.values.map(&:to_s).sort.join(',')
    end

    def push(obj)
      case obj
      when Nagios::Hostgroup
        push_object(obj, @hostgroups)
      when Nagios::Host
        push_object(obj, @parents)
      when Nagios::Contact
        push_object(obj, @contacts)
      when Nagios::Contactgroup
        push_object(obj, @contact_groups)
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
      when Nagios::Hostgroup
        if @hostgroups.key?(obj.to_s)
          pop_object(obj, @hostgroups)
          obj.pop(self)
        end
      when Nagios::Host
        if @parents.key?(obj.to_s)
          pop_object(obj, @parents)
          obj.pop(self)
        end
      when Nagios::Contact
        if @contacts.keys?(obj.to_s)
          pop_object(obj, @contacts)
          obj.pop(self)
        end
      when Nagios::Contactgroup
        if @contact_groups.keys?(obj.to_s)
          pop_object(obj, @contact_groups)
          obj.pop(self)
        end
      when Nagios::Timeperiod
        @check_period = nil if @check_period == obj
        @notification_period = nil if @notification_period == obj
      when Nagios::CustomOption
        if @custom_options.keys?(obj.to_s)
          pop_object(obj, @custom_options)
          obj.pop(self)
        end
      end
    end
    # rubocop:enable MethodLength

    def self.create(name)
      Nagios.instance.find(Nagios::Host.new(name))
    end

    def to_s
      host_name
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

    def active_checks_enabled=(arg)
      @active_checks_enabled = check_bool(arg)
    end

    def passive_checks_enabled=(arg)
      @passive_checks_enabled = check_bool(arg)
    end

    def obsess_over_host=(arg)
      @obsess_over_host = check_bool(arg)
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

    # check other options

    # initial_state
    # By default Nagios will assume that all hosts are in UP states when it starts.
    # You can override the initial state for a host by using this directive.
    # Valid options are:
    # o = UP,
    # d = DOWN,
    # u = UNREACHABLE.
    def initial_state=(arg)
      @initial_state = check_state_options(arg, %w(o d u), 'initail_state')
    end

    # flap_detection_options
    # This directive is used to determine what host states the flap detection logic will use for this host.
    # Valid options are a combination of one or more of the following:
    # o = UP states,
    # d = DOWN states,
    # u = UNREACHABLE states.
    def flap_detection_options=(arg)
      @flap_detection_options = check_state_options(arg, %w(o d u), 'flap_detection_options')
    end

    # stalking_options
    # This directive determines which host states "stalking" is enabled for.
    # Valid options are a combination of one or more of the following:
    # o = stalk on UP states,
    # d = stalk on DOWN states,
    # u = stalk on UNREACHABLE states.
    def stalking_options=(arg)
      @stalking_options = check_state_options(arg, %w(o d u), 'stalking_options')
    end

    # notification_options
    # This directive is used to determine when notifications for the host should be sent out.
    # Valid options are a combination of one or more of the following:
    #   d = send notifications on a DOWN state,
    #   u = send notifications on an UNREACHABLE state,
    #   r = send notifications on recoveries (OK state),
    #   f = send notifications when the host starts and stops flapping
    #   s = send notifications when scheduled downtime starts and ends.
    #   If you specify n (none) as an option, no host notifications will be sent out.
    #   If you do not specify any notification options, Nagios will assume that you want notifications
    #   to be sent out for all possible states.
    #   Example: If you specify d,r in this field, notifications will only be sent out when the host
    #   goes DOWN and when it recovers from a DOWN state.

    def notification_options=(arg)
      @notification_options = check_state_options(arg, %w(d u r f s n), 'notification_options')
    end

    private

    def config_options
      {
        'name'                         => 'name',
        'use'                          => 'use',
        'host_name'                    => 'host_name',
        'hostgroups_list'              => 'hostgroups',
        'alias'                        => 'alias',
        'display_name'                 => 'display_name',
        'address'                      => 'address',
        'parents_list'                 => 'parents',
        'check_command'                => 'check_command',
        'initial_state'                => 'initial_state',
        'max_check_attempts'           => 'max_check_attempts',
        'check_interval'               => 'check_interval',
        'retry_interval'               => 'retry_interval',
        'active_checks_enabled'        => 'active_checks_enabled',
        'passive_checks_enabled'       => 'passive_checks_enabled',
        'check_period'                 => 'check_period',
        'obsess_over_host'             => 'obsess_over_host',
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
        'contacts_list'                => 'contacts',
        'contact_groups_list'          => 'contact_groups',
        'notification_interval'        => 'notification_interval',
        'first_notification_delay'     => 'first_notification_delay',
        'notification_period'          => 'notification_period',
        'notification_options'         => 'notification_options',
        'notifications_enabled'        => 'notifications_enabled',
        'notifications'                => nil,
        'stalking_options'             => 'stalking_options',
        'notes'                        => 'notes',
        'notes_url'                    => 'notes_url',
        'action_url'                   => 'action_url',
        'icon_image'                   => 'icon_image',
        'icon_image_alt'               => 'icon_image_alt',
        'vrml_image'                   => 'vrml_image',
        'statusmap_image'              => 'statusmap_image',
        '_2d_coords'                   => '2d_coords',
        '_3d_coords'                   => '3d_coords',
        'register'                     => 'register',
      }
    end
    # rubocop:enable MethodLength

    def merge_members(obj)
      obj.parents.each { |m| push(m) }
      obj.contacts.each { |m| push(m) }
      obj.contact_groups.each { |m| push(m) }
      obj.hostgroups.each { |m| push(m) }
      obj.custom_options.each { |_, m| push(m) }
    end
  end
end
