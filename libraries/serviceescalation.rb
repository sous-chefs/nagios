#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: serviceescalation
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
  #  This class holds all methods with regard to serviceescalation options,
  #  that are used within nagios configurations.
  #
  class Serviceescalation < Nagios::Base
    attr_reader   :service_description,
                  :host_name,
                  :hostgroup_name,
                  :servicegroup_name,
                  :contacts,
                  :contact_groups

    attr_accessor :first_notification,
                  :last_notification,
                  :notification_interval,
                  :escalation_options,
                  :escalation_period

    def initialize(name)
      @service_description = name
      @contacts            = {}
      @contact_groups      = {}
      @host_name           = {}
      @hostgroup_name      = {}
      @servicegroup_name   = {}
      super()
    end

    def definition
      configured = configured_options
      unless blank?(servicegroup_name)
        configured.delete('service_description')
        configured.delete('host_name')
      end
      get_definition(configured, 'serviceescalation')
    end

    def contacts_list
      @contacts.values.map(&:to_s).sort.join(',')
    end

    def contact_groups_list
      @contact_groups.values.map(&:to_s).sort.join(',')
    end

    def host_name_list
      @host_name.values.map(&:to_s).sort.join(',')
    end

    def hostgroup_name_list
      @hostgroup_name.values.map(&:to_s).sort.join(',')
    end

    def servicegroup_name_list
      @servicegroup_name.values.map(&:to_s).sort.join(',')
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'contacts', Nagios::Contact)
      update_members(hash, 'contact_groups', Nagios::Contactgroup)
      update_members(hash, 'host_name', Nagios::Host)
      update_members(hash, 'hostgroup_name', Nagios::Hostgroup)
      update_members(hash, 'servicegroup_name', Nagios::Servicegroup)
    end

    def push(obj)
      case obj
      when Nagios::Host
        push_object(obj, @host_name)
      when Nagios::Hostgroup
        push_object(obj, @hostgroup_name)
      when Nagios::Servicegroup
        push_object(obj, @servicegroup_name)
      when Nagios::Contact
        push_object(obj, @contacts)
      when Nagios::Contactgroup
        push_object(obj, @contact_groups)
      when Nagios::Timeperiod
        @escalation_period = obj
      end
    end

    def pop(obj)
      return if obj == self
      case obj
      when Nagios::Host
        if @host_name.keys?(obj.to_s)
          pop_object(obj, @host_name)
          pop(self, obj)
        end
      when Nagios::Hostgroup
        if @hostgroup_name.keys?(obj.to_s)
          pop_object(obj, @hostgroup_name)
          pop(self, obj)
        end
      when Nagios::Servicegroup
        if @servicegroup_name.keys?(obj.to_s)
          pop_object(obj, @servicegroup_name)
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
      when Nagios::Timeperiod
        @escalation_period = nil if @escalation_period == obj
      end
    end
    # rubocop:enable MethodLength

    def to_s
      service_description
    end

    # check the integer options
    # default = nil

    def first_notification=(int)
      @first_notification = check_integer(int)
    end

    def last_notification=(int)
      @last_notification = check_integer(int)
    end

    def notification_interval=(int)
      @notification_interval = check_integer(int)
    end

    # check other options

    def escalation_options=(arg)
      @escalation_options = check_state_options(arg, %w(w u c r), 'escalation_options')
    end

    private

    def config_options
      {
        'name'                   => 'name',
        'use'                    => 'use',
        'service_description'    => 'service_description',
        'contacts_list'          => 'contacts',
        'contact_groups_list'    => 'contact_groups',
        'escalation_period'      => 'escalation_period',
        'host_name_list'         => 'host_name',
        'hostgroup_name_list'    => 'hostgroup_name',
        'servicegroup_name_list' => 'servicegroup_name',
        'escalation_options'     => 'escalation_options',
        'first_notification'     => 'first_notification',
        'last_notification'      => 'last_notification',
        'notification_interval'  => 'notification_interval',
        'register'               => 'register',
      }
    end
    # rubocop:enable MethodLength

    def merge_members(obj)
      obj.contacts.each { |m| push(m) }
      obj.host_name.each { |m| push(m) }
      obj.contact_groups.each { |m| push(m) }
      obj.hostgroup_name.each { |m| push(m) }
      obj.servicegroup_name.each { |m| push(m) }
    end
  end
end
