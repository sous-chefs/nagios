#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: hostgroup
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
  # This class holds all methods with regard to hostgroup options,
  # that are used within nagios configurations.
  #
  class Hostgroup < Nagios::Base
    attr_reader   :hostgroup_name,
                  :members,
                  :hostgroup_members

    attr_accessor :alias,
                  :notes,
                  :notes_url,
                  :action_url

    def initialize(hostgroup_name)
      @hostgroup_name = hostgroup_name
      @members = {}
      @hostgroup_members = {}
      super()
    end

    def definition
      get_definition(configured_options, 'hostgroup')
    end

    def hostgroup_members_list
      @hostgroup_members.values.map(&:to_s).sort.join(',')
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'members', Nagios::Host, true)
      update_members(hash, 'hostgroups_members', Nagios::Hostgroup, true)
    end

    def members_list
      @members.values.map(&:to_s).sort.join(',')
    end

    def push(obj)
      case obj
      when Nagios::Host
        push_object(obj, @members)
      when Nagios::Hostgroup
        push_object(obj, @hostgroup_members)
      end
    end

    def pop(obj)
      return if obj == self
      case obj
      when Nagios::Host
        if @members.key?(obj.to_s)
          pop_object(obj, @members)
          obj.pop(obj)
        end
      when Nagios::Hostgroup
        if @hostgroups_members.key?(obj.to_s)
          pop_object(obj, @hostgroup_members)
          obj.pop(obj)
        end
      end
    end
    # rubocop:enable MethodLength

    def self.create(name)
      Nagios.instance.find(Nagios::Hostgroup.new(name))
    end

    def to_s
      hostgroup_name
    end

    private

    def config_options
      {
        'name'                   => 'name',
        'use'                    => 'use',
        'hostgroup_name'         => 'hostgroup_name',
        'members_list'           => 'members',
        'hostgroup_members_list' => 'hostgroup_members',
        'alias'                  => 'alias',
        'notes'                  => 'notes',
        'notes_url'              => 'notes_url',
        'action_url'             => 'action_url',
        'register'               => 'register',
      }
    end
    # rubocop:enable MethodLength

    def merge_members(obj)
      obj.members.each { |m| push(m) }
      obj.hostgroup_members.each { |m| push(m) }
    end
  end
end
