#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
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
    end

    def definition
      configured = get_configured_options
      (['define hostgroup{'] + get_definition_options(configured) + ['}']).join("\n")
    end

    def hostgroup_members
      (@hostgroup_members.map {|k,v| v.id}).join(',')
    end

    def id
      self.hostgroup_name
    end

    def import(hash)
      update_options(hash)
      update_members(hash, 'members', Nagios::Host, true)
      update_members(hash, 'hostgroups_members', Nagios::Hostgroup, true)
    end

    def members
      (@members.map {|k,v| v.id}).join(',')
    end
 
    def push(obj)
      case obj
      when Nagios::Host
        push_object(obj, @members)
      when Nagios::Hostgroup
        push_object(obj, @hostgroup_members)
      end
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Hostgroup.new(name))
    end

    def to_s
      self.hostgroup_name
    end

    private

    def config_options
      { 
        'name'              => 'name',
        'use'               => 'use',
        'hostgroup_name'    => 'hostgroup_name',
        'members'           => 'members',
        'hostgroup_members' => 'hostgroup_members',
        'alias'             => 'alias',
        'notes'             => 'notes',
        'notes_url'         => 'notes_url',
        'action_url'        => 'action_url', 
        'register'          => 'register' 
      }      
    end

    def merge_members(obj)
      obj.members.each { |m| self.push(m) }
      obj.hostgroup_members.each { |m| self.push(m) }
    end

  end
end
