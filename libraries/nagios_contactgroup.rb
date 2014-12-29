#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Library:: nagios_contactgroup
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
  class Contactgroup < Nagios::Base

    attr_reader   :contactgroup_name,
                  :members,
                  :contactgroup_members

    attr_accessor :alias
 
    def initialize(contactgroup_name)
      @contactgroup_name = contactgroup_name
      @members = {}
      @contactgroup_members = {}
    end

    def contactgroup_members
      (@contactgroup_members.map {|k,v| v.id}).join(',')
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Contactgroup.new(name))
    end

    def definition
      configured = get_configured_options
      (['define contactgroup{'] + get_definition_options(configured) + ['}']).join("\n")
    end

    def id
      self.contactgroup_name
    end

    def import_hash(hash)
      update_options(hash)
      update_members(hash, 'members', Nagios::Contact, true)
      update_members(hash, 'contactgroups_members', Nagios::Contactgroup, true)
    end

    def members
      (@members.map {|k,v| v.id}).join(',')
    end

    def push(obj)
      case obj
      when Nagios::Contact
        push_object(obj, @members)
      when Nagios::Contactgroup
        push_object(obj, @contactgroup_members)
      end
    end

    def to_s
      self.contactgroup_name
    end
 
    private

    def config_options
      {
        'name'                 => 'name',
        'use'                  => 'use',
        'contactgroup_name'    => 'contactgroup_name',
        'members'              => 'members',
        'contactgroup_members' => 'contactgroup_members',
        'alias'                => 'alias',
        'register'             => 'register'
      }
    end

    def merge_members(obj)
      obj.members.each { |m| self.push(m) }
      obj.contactgroup_members.each { |m| self.push(m) }
    end

  end
end
