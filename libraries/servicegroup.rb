#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
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
        'action_url'                => 'action_url'
      }
    end

    def convert_hostgroup_hash(hash)
      result = []
      hash.each do |group_name, group_members|
        group_members.each do |member|
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
        service_obj.hostgroups.each do |_, hostgroup_obj|
          hostgroup_obj.members.each { |host_name, _| hostgroup_array << host_name }
        end
        hostgroup_hash[service_name] = hostgroup_array
      end
      convert_hostgroup_hash(hostgroup_hash)
    end

    def merge_members(obj)
      obj.members.each { |m| push(m) }
      obj.servicegroup_members.each { |m| push(m) }
    end
  end
end
