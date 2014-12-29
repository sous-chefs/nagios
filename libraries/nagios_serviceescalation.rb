#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Library:: nagios_serviceescalation
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

require_relative 'nagios_base'

class Nagios
  class Serviceescalation < Nagios::Base

    attr_reader   :service_description,
                  :host_name,
                  :hostgroup_name,
                  :contacts,
                  :contact_groups,
                  :escalation_period

    attr_accessor :first_notification,
                  :last_notification,
                  :notification_interval,
                  :escalation_options

    def initialize(name)
      @service_description = name
      @name                = name
      @contacts            = {}
      @contact_groups      = {}
      @host_name           = {}
      @hostgroup_name      = {}
      @register            = 0
    end

    def definition
      configured = get_configured_options
      (['define serviceescalation{'] + get_definition_options(configured) + ['}']).join("\n")
    end

    def contacts
      (@contacts.map {|k,v| v.id}).join(',')
    end

    def contact_groups
      (@contact_groups.map {|k,v| v.id}).join(',')
    end

    def host_name
      (@host_name.map {|k,v| v.id}).join(',')
    end

    def hostgroup_name
      (@hostgroup_name.map {|k,v| v.id}).join(',')
    end

    def id
      self.service_description
    end

    def import_hash(hash)
      update_options(hash)
      update_members(hash, 'contacts', Nagios::Contact)
      update_members(hash, 'contact_groups', Nagios::Contactgroup)
      update_members(hash, 'host_name', Nagios::Host)
      update_members(hash, 'hostgroup_name', Nagios::Hostgroup)
    end

    def push(obj)
      case obj
      when Nagios::Host
        push_object(obj, @host_name)
      when Nagios::Hostgroup
        push_object(obj, @hostgroup_name)
      when Nagios::Contact
        push_object(obj, @contacts)
      when Nagios::Contactgroup
        push_object(obj, @contact_groups)
      when Nagios::Timeperiod
        @escalation_period = obj    
      end
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Serviceescalation.new(name))
    end

    def to_s
      self.service_description
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
      @escalation_options = check_state_options(arg, ['w','u','c','r'], 'escalation_options')
    end

    private

    def config_options
      {
        'name'                  => 'name',
        'use'                   => 'use',
        'service_description'   => 'service_description',
        'contacts'              => 'contacts',
        'contact_groups'        => 'contact_groups',
        'escalation_period'     => 'escalation_period',
        'host_name'             => 'host_name',
        'hostgroup_name'        => 'hostgroup_name',
        'escalation_options'    => 'escalation_options',
        'first_notification'    => 'first_notification', 
        'last_notification'     => 'last_notification',
        'notification_interval' => 'notification_interval',
        'register'              => 'register' 
      }
    end

    def merge_members(obj)
      obj.contacts.each { |m| self.push(m) }
      obj.host_name.each { |m| self.push(m) }
      obj.contact_groups.each { |m| self.push(m) }
      obj.hostgroup_name.each { |m| self.push(m) }
    end

  end
end
