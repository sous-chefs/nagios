#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Library:: nagios
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

class Nagios
  attr_reader :commands,
              :contactgroups,
              :contacts,
              :hostgroups,
              :hosts,
              :servicegroups,
              :services,
              :timeperiods,
              :hostdependencies,
              :hostescalations,
              :servicedependencies,
              :serviceescalations

  attr_accessor :host_name_attribute,
                :normalize_hostname,
                :default_command,
                :default_contactgroup,
                :default_contact,
                :default_hostgroup,
                :default_host,
                :default_servicegroup,
                :default_service,
                :default_timeperiod

  def initialize
    @commands            = {}
    @contactgroups       = {}
    @contacts            = {}
    @hostgroups          = {}
    @hosts               = {}
    @servicegroups       = {}
    @services            = {}
    @timeperiods         = {}
    @hostdependencies    = {}
    @hostescalations     = {}
    @servicedependencies = {}
    @serviceescalations  = {}
    @host_name_attribute = 'hostname'
    @normalize_hostname  = false
  end

  @instance = Nagios.new

  def self.instance
    @instance
  end

  def find(obj)
    case obj
    when Nagios::Command
      find_object(obj, @commands)
    when Nagios::Contact
      find_object(obj, @contacts)
    when Nagios::Contactgroup
      find_object(obj, @contactgroups)
    when Nagios::Host
      find_object(obj, @hosts)
    when Nagios::Hostgroup
      find_object(obj, @hostgroups)
    when Nagios::Service
      find_object(obj, @services)
    when Nagios::Servicegroup
      find_object(obj, @servicegroups)
    when Nagios::Timeperiod
      find_object(obj, @timeperiods)
    when Nagios::Hostdependency
      find_object(obj, @hostdependencies)
    when Nagios::Hostescalation
      find_object(obj, @hostescalations)
    when Nagios::Servicedependency
      find_object(obj, @servicedependencies)
    when Nagios::Serviceescalation
      find_object(obj, @serviceescalations)
    end
  end

  def normalize_hostname=(expr)  
    if expr == true
      @normalize_hostname = true 
    elsif expr =~ /y|yes|true|1/i
      @normalize_hostname = true
    else
      @normalize_hostname = false
    end
  end

  def push(obj)
    case obj
    when Chef::Node
      push_node(obj)
    when Nagios::Command
      push_object(obj)
    when Nagios::Contact
      push_object(obj)
    when Nagios::Contactgroup
      push_object(obj)
    when Nagios::Host 
      push_object(obj)
    when Nagios::Hostgroup
      push_object(obj)
    when Nagios::Service
      push_object(obj)
    when Nagios::Servicegroup
      push_object(obj)
    when Nagios::Timeperiod
      push_object(obj)
    when Nagios::Hostdependency
      push_object(obj)
    when Nagios::Hostescalation
      push_object(obj)
    when Nagios::Servicedependency
      push_object(obj)
    when Nagios::Serviceescalation
      push_object(obj)
    else
      Chef::Log.fail("Nagios error: Pushing unknown object: #{obj.class} into Nagios.instance")
      fail
    end
  end
  
  private

  def blank?(expr)
    return true if expr.nil?
    case expr
    when 'String', String
      return true if expr == ""
    when 'Array', 'Hash', Array, Hash
      return true if expr.empty?
    else
      return false
    end
    return false
  end

  def find_object(obj, hash)
    current = hash[obj.id]
    if current.nil?
      Chef::Log.debug("Nagios debug: Creating entry for #{obj.class} with id: #{obj.id}")
      hash[obj.id] = obj
      obj
    else
      Chef::Log.debug("Nagios debug: Found entry for #{obj.class} with id: #{obj.id}")
      current
    end
  end

  def get_hostname(obj)
    return obj[@host_name_attribute] unless blank?(obj[@host_name_attribute])
    return obj['hostname'] unless blank?(obj['hostname'])
    obj['name']
  end

  def push_node(obj)
    groups = obj['roles'].dup
    groups += [ obj['os'] ]
    groups += [ obj.chef_environment ]

    host = self.find(Nagios::Host.new(get_hostname(obj)))
    host.import(obj['nagios']) unless obj['nagios'].nil?
    
    # TODO (merge the ip_to_monitor funtion into this logic here)
    host.address = obj['ipaddress']

    groups.each do |r|
      hg = self.find(Nagios::Hostgroup.new(r))
      hg.push(host)
      host.push(hg)
    end
  end
  
  def push_object(obj)
    object = self.find(obj.class.new(obj.id))
    object.merge!(obj)
  end

end
