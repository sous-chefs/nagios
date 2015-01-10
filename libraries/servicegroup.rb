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

    def id
      servicegroup_name
    end

    def import(hash)
      update_members(hash, 'members', Nagios::Service, true)
      update_members(hash, 'servicegroup_members', Nagios::Servicegroup, true)
    end

    def members
      @members.values.map(&:id).sort.join(',')
    end

    def push(obj)
      case obj
      when Nagios::Service
        push_object(obj, @members)
      when Nagios::Servicegroup
        push_object(obj, @servicegroup_members)
      end
    end

    def servicegroup_members
      @servicegroup_members.values.map(&:id).sort.join(',')
    end

    private

    def config_options
      {
        'servicegroup_name'    => 'servicegroup_name',
        'members'              => 'members',
        'servicegroup_members' => 'servicegroup_members',
        'alias'                => 'alias',
        'notes'                => 'notes',
        'notes_url'            => 'notes_url',
        'action_url'           => 'action_url'
      }
    end

    def merge_members(obj)
      obj.members.each { |m| push(m) }
      obj.servicegroup_members.each { |m| push(m) }
    end
  end
end
