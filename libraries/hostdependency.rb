#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: hostdependency
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
  # This class holds all methods with regard to hostdependency options,
  # that are used within nagios configurations.
  #
  class Hostdependency < Nagios::Base
    attr_reader   :dependent_name,
                  :dependency_period,
                  :dependent_host_name,
                  :dependent_hostgroup_name,
                  :host_name,
                  :hostgroup_name

    attr_accessor :inherits_parent,
                  :execution_failure_criteria,
                  :notification_failure_criteria

    def initialize(name)
      @dependent_name           = name
      @host_name                = {}
      @hostgroup_name           = {}
      @dependent_host_name      = {}
      @dependent_hostgroup_name = {}
      super()
    end

    def definition
      get_definition(configured_options, 'hostdependency')
    end

    def dependent_host_name_list
      @dependent_host_name.values.map(&:to_s).sort.join(',')
    end

    def dependent_hostgroup_name_list
      @dependent_hostgroup_name.values.map(&:to_s).sort.join(',')
    end

    def host_name_list
      @host_name.values.map(&:to_s).sort.join(',')
    end

    def hostgroup_name_list
      @hostgroup_name.values.map(&:to_s).sort.join(',')
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'host_name', Nagios::Host)
      update_members(hash, 'hostgroup_name', Nagios::Hostgroup)
      update_dependency_members(hash, 'dependent_host_name', Nagios::Host)
      update_dependency_members(hash, 'dependent_hostgroup_name', Nagios::Hostgroup)
    end

    def push(obj)
      case obj
      when Nagios::Host
        push_object(obj, @host_name)
      when Nagios::Hostgroup
        push_object(obj, @hostgroup_name)
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
      when Nagios::Timeperiod
        @dependency_period = nil if @dependency_period == obj
      end
    end

    def pop_dependency(obj)
      return if obj == self
      case obj
      when Nagios::Host
        if @dependent_host_name.keys?(obj.to_s)
          pop_object(obj, @dependent_host_name)
          pop(self, obj)
        end
      when Nagios::Hostgroup
        if @dependent_hostgroup_name.keys?(obj.to_s)
          pop_object(obj, @dependent_hostgroup_name)
          pop(self, obj)
        end
      end
    end
    # rubocop:enable MethodLength

    def self.create(name)
      Nagios.instance.find(Nagios::Hostdependency.new(name))
    end

    def to_s
      dependent_name
    end

    # check the True/False options
    # default = nil

    def inherits_parent=(arg)
      @inherits_parent = check_bool(arg)
    end

    # check other options

    def execution_failure_criteria=(arg)
      @execution_failure_criteria = check_state_options(arg, %w(o d u p n), 'execution_failure_criteria')
    end

    def notification_failure_criteria=(arg)
      @notification_failure_criteria = check_state_options(arg, %w(o d u p n), 'notification_failure_criteria')
    end

    private

    def config_options
      {
        'dependent_name'                => nil,
        'dependency_period'             => 'dependency_period',
        'dependent_host_name_list'      => 'dependent_host_name',
        'dependent_hostgroup_name_list' => 'dependent_hostgroup_name',
        'host_name_list'                => 'host_name',
        'hostgroup_name_list'           => 'hostgroup_name',
        'inherits_parent'               => 'inherits_parent',
        'execution_failure_criteria'    => 'execution_failure_criteria',
        'notification_failure_criteria' => 'notification_failure_criteria',
      }
    end
    # rubocop:enable MethodLength

    def merge_members(obj)
      obj.host_name.each { |m| push(m) }
      obj.hostgroup_name.each { |m| push(m) }
      obj.dependent_host_name.each { |m| push_dependency(m) }
      obj.dependent_hostgroup_name.each { |m| push_dependency(m) }
    end
  end
end
# rubocop:enable ClassLength
