#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: contactgroup
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

require_relative 'nagios'

class Nagios
  #
  # This class holds all methods with regard to contactgroup options,
  # that are used within nagios configurations.
  #
  class Contactgroup < Nagios::Base
    attr_reader   :contactgroup_name,
                  :members,
                  :contactgroup_members

    attr_accessor :alias

    def initialize(contactgroup_name)
      @contactgroup_name = contactgroup_name
      @members = {}
      @contactgroup_members = {}
      super()
    end

    def contactgroup_members_list
      @contactgroup_members.values.map(&:to_s).sort.join(',')
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Contactgroup.new(name))
    end

    def definition
      get_definition(configured_options, 'contactgroup')
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'members', Nagios::Contact, true)
      update_members(hash, 'contactgroups_members', Nagios::Contactgroup, true)
    end

    def members_list
      @members.values.map(&:to_s).sort.join(',')
    end

    def push(obj)
      case obj
      when Nagios::Contact
        push_object(obj, @members)
      when Nagios::Contactgroup
        push_object(obj, @contactgroup_members)
      end
    end

    def pop(obj)
      return if obj == self
      case obj
      when Nagios::Contact
        if @members.keys?(obj.to_s)
          pop_object(obj, @members)
          pop(self, obj)
        end
      when Nagios::Contactgroup
        if @contactgroups_members.keys?(obj.to_s)
          pop_object(obj, @contactgroup_members)
          pop(self, obj)
        end
      end
    end
    # rubocop:enable MethodLength

    def to_s
      contactgroup_name
    end

    private

    def config_options
      {
        'name'                      => 'name',
        'use'                       => 'use',
        'contactgroup_name'         => 'contactgroup_name',
        'members_list'              => 'members',
        'contactgroup_members_list' => 'contactgroup_members',
        'alias'                     => 'alias',
        'register'                  => 'register',
      }
    end

    def merge_members(obj)
      obj.members.each { |m| push(m) }
      obj.contactgroup_members.each { |m| push(m) }
    end
  end
end
