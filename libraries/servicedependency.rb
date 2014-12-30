#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Library:: servicedependency
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
  class Servicedependency < Nagios::Base

    attr_reader   :service_description,
                  :dependency_period,
                  :dependent_host_name,
                  :dependent_hostgroup_name,
                  :dependent_servicegroup_name,
                  :host_name,
                  :hostgroup_name,
                  :servicegroup_name

    attr_accessor :dependent_service_description,
                  :inherits_parent, 
                  :execution_failure_criteria,
                  :notification_failure_criteria

    def initialize(name)
      @service_description         = name
      @host_name                   = {}
      @hostgroup_name              = {}
      @servicegroup_name           = {}
      @dependent_host_name         = {}
      @dependent_hostgroup_name    = {}
      @dependent_servicegroup_name = {}
    end

    def definition
      configured = get_configured_options
      (['define servicedependency{'] + get_definition_options(configured) + ['}']).join("\n")
    end

    def dependent_host_name
      (@dependent_host_name.map {|k,v| v.id}).join(',')
    end

    def dependent_hostgroup_name
      (@dependent_hostgroup_name.map {|k,v| v.id}).join(',')
    end

    def dependent_servicegroup_name
      (@dependent_servicegroup_name.map {|k,v| v.id}).join(',')
    end

    def host_name
      (@host_name.map {|k,v| v.id}).join(',')
    end

    def hostgroup_name
      (@hostgroup_name.map {|k,v| v.id}).join(',')
    end

    def servicegroup_name
      (@servicegroup_name.map {|k,v| v.id}).join(',')
    end

    def id
      self.service_description
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'host_name', Nagios::Host)
      update_members(hash, 'hostgroup_name', Nagios::Hostgroup)
      update_members(hash, 'servicegroup_name', Nagios::Servicegroup)
      update_dependency_members(hash, 'dependent_host_name', Nagios::Host)
      update_dependency_members(hash, 'dependent_hostgroup_name', Nagios::Hostgroup)
      update_dependency_members(hash, 'dependent_servicegroup_name', Nagios::Servicegroup)
    end

    def push(obj)
      case obj
      when Nagios::Host
        push_object(obj, @host_name)
      when Nagios::Hostgroup
        push_object(obj, @hostgroup_name)
      when Nagios::Servicegroup
        push_object(obj, @servicegroup_name)
      when Nagios::Timeperiod
        @dependency_period = obj    
      end
    end

    def push_dependency(obj)
      case obj
      when Nagios::Host
        push_object(obj, @dependent_host_name)
      when Nagios::Hostgroup
        push_object(obj, @dependent_hostgroup_name)
      when Nagios::Servicegroup
        push_object(obj, @dependent_servicegroup_name)
      end
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Servicedependency.new(name))
    end

    def to_s
      self.service_description
    end

    # check the True/False options
    # default = nil

    def inherits_parent=(arg)
      @inherits_parent = check_bool(arg)
    end

    # check other options

    def execution_failure_criteria=(arg)
      @execution_failure_criteria = check_state_options(arg, ['o','w','u','c','p','n'], 'execution_failure_criteria')
    end

    def notification_failure_criteria=(arg)
      @notification_failure_criteria = check_state_options(arg, ['o','w','u','c','p','n'], 'notification_failure_criteria')
    end

    private

    def config_options
      {
        #'name'                          => 'name',
        #'use'                           => 'use',
        'dependency_period'             => 'dependency_period',
        'dependent_host_name'           => 'dependent_host_name',
        'dependent_hostgroup_name'      => 'dependent_hostgroup_name',
        'dependent_servicegroup_name'   => 'dependent_servicegroup_name',
        'servicegroup_name'             => 'servicegroup_name',
        'dependent_service_description' => 'dependent_service_description',
        'host_name'                     => 'host_name',
        'hostgroup_name'                => 'hostgroup_name',
        'inherits_parent'               => 'inherits_parent',
        'execution_failure_criteria'    => 'execution_failure_criteria', 
        'notification_failure_criteria' => 'notification_failure_criteria'
        #'register'                      => 'register' 
      }
    end

    def merge_members(obj)
      obj.host_name.each { |m| self.push(m) }
      obj.hostgroup_name.each { |m| self.push(m) }
      obj.servicegroup_name.each { |m| self.push(m) }
      obj.dependent_host_name.each { |m| self.push_dependency(m) }
      obj.dependent_hostgroup_name.each { |m| self.push_dependency(m) }
      obj.dependent_servicegroup_name.each { |m| self.dependent_servicegroup_name(m) }
    end

  end
end
