#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: servicegroup
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
  #  This class holds all methods with regard to servicegroup options,
  #  that are used within nagios configurations.
  #
  class Servicegroup < Nagios::Base
    attr_reader   :servicegroup_name,
                  :members,
                  :servicegroup_members

    attr_accessor :alias,
                  :notes,
                  :notes_url,
                  :action_url

    def initialize(servicegroup_name)
      @servicegroup_name = servicegroup_name
      @members = {}
      @servicegroup_members = {}
      super()
    end

    def definition
      get_definition(configured_options, 'servicegroup')
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'members', Nagios::Service, true)
      update_members(hash, 'servicegroup_members', Nagios::Servicegroup, true)
    end

    def members_list
      result = lookup_hostgroup_members
      result.join(',')
    end

    def push(obj)
      case obj
      when Nagios::Service
        push_object(obj, @members)
      when Nagios::Servicegroup
        push_object(obj, @servicegroup_members)
      end
    end

    def pop(obj)
      return if obj == self
      case obj
      when Nagios::Service
        if @members.keys?(obj.to_s)
          pop_object(obj, @members)
          pop(self, obj)
        end
      when Nagios::Servicegroup
        if @servicegroup_members.keys?(obj.to_s)
          pop_object(obj, @servicegroup_members)
          pop(self, obj)
        end
      end
    end
    # rubocop:enable MethodLength

    def self.create(name)
      Nagios.instance.find(Nagios::Servicegroup.new(name))
    end

    def servicegroup_members_list
      @servicegroup_members.values.map(&:to_s).sort.join(',')
    end

    def to_s
      servicegroup_name
    end

    private

    def config_options
      {
        'servicegroup_name'         => 'servicegroup_name',
        'members_list'              => 'members',
        'servicegroup_members_list' => 'servicegroup_members',
        'alias'                     => 'alias',
        'notes'                     => 'notes',
        'notes_url'                 => 'notes_url',
        'action_url'                => 'action_url',
      }
    end

    def convert_hostgroup_hash(hash)
      result = []
      hash.sort.to_h.each do |group_name, group_members|
        group_members.sort.each do |member|
          result << member
          result << group_name
        end
      end
      result
    end

    def lookup_hostgroup_members
      hostgroup_hash = {}
      @members.each do |service_name, service_obj|
        hostgroup_array = []
        service_obj.hostgroups.each do |hostgroup_name, hostgroup_obj|
          if service_obj.not_modifiers['hostgroup_name'][hostgroup_name] != '!'
            hostgroup_array += hostgroup_obj.members.keys
          else
            hostgroup_array -= hostgroup_obj.members.keys
          end
        end
        hostgroup_hash[service_name] = hostgroup_array
      end
      convert_hostgroup_hash(hostgroup_hash)
    end
    # rubocop:enable MethodLength

    def merge_members(obj)
      obj.members.each { |m| push(m) }
      obj.servicegroup_members.each { |m| push(m) }
    end
  end
end
