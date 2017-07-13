#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
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
#

#
# This class holds all methods with regard to the nagios model.
#
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
              :serviceescalations,
              :resources

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
    @hostescalations     = []
    @servicedependencies = {}
    @serviceescalations  = []
    @resources           = {}
    @host_name_attribute = 'hostname'
    @normalize_hostname  = false
  end
  # rubocop:enable MethodLength

  def commands
    Hash[@commands.sort]
  end

  def contactgroups
    Hash[@contactgroups.sort]
  end

  def contacts
    Hash[@contacts.sort]
  end

  def delete(hash, key)
    case hash
    when 'command'
      @commands.delete(key)
    when 'contactgroup'
      @contactgroups.delete(key)
    when 'contact'
      @contacts.delete(key)
    when 'hostgroup'
      @hostgroups.delete(key)
    when 'host'
      @hosts.delete(key)
    when 'servicegroup'
      @servicegroups.delete(key)
    when 'service'
      @services.delete(key)
    when 'timeperiod'
      @timeperiods.delete(key)
    when 'hostdependency'
      @hostdependencies.delete(key)
    when 'hostescalation'
      @hostescalations.delete(key)
    when 'servicedependency'
      @servicedependencies.delete(key)
    when 'serviceescalation'
      @serviceescalations.delete(key)
    when 'resource'
      @resources.delete(key)
    end
  end
  # rubocop:enable MethodLength

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
    when Nagios::Servicedependency
      find_object(obj, @servicedependencies)
    when Nagios::Resource
      find_object(obj, @resources)
    end
  end
  # rubocop:enable MethodLength

  def hosts
    Hash[@hosts.sort]
  end

  def hostdependencies
    Hash[@hostdependencies.sort]
  end

  def hostgroups
    Hash[@hostgroups.sort]
  end

  def normalize_hostname=(expr)
    @normalize_hostname = (expr == true || !(expr =~ /y|yes|true|1/).nil?)
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
      @hostescalations.push(obj)
    when Nagios::Servicedependency
      push_object(obj)
    when Nagios::Serviceescalation
      @serviceescalations.push(obj)
    when Nagios::Resource
      push_object(obj)
    else
      Chef::Log.fail("Nagios error: Pushing unknown object: #{obj.class} into Nagios.instance")
      raise
    end
  end
  # rubocop:enable MethodLength

  def timeperiods
    Hash[@timeperiods.sort]
  end

  def resources
    Hash[@resources.sort]
  end

  def self.instance
    @instance ||= Nagios.new
  end

  def services
    Hash[@services.sort]
  end

  def servicedependencies
    Hash[@servicedependencies.sort]
  end

  def servicegroups
    Hash[@servicegroups.sort]
  end

  private

  def blank?(expr)
    return true if expr.nil?
    case expr
    when 'String', String
      return true if expr == ''
    when 'Array', 'Hash', Array, Hash
      return true if expr.empty?
    else
      return false
    end
    false
  end

  def find_object(obj, hash)
    current = hash[obj.to_s]
    if current.nil?
      Chef::Log.debug("Nagios debug: Creating entry for #{obj.class} with name: #{obj}")
      hash[obj.to_s] = obj
      obj
    else
      Chef::Log.debug("Nagios debug: Found entry for #{obj.class} with name: #{obj}")
      current
    end
  end

  def get_groups(obj)
    groups = obj['roles'].nil? ? [] : obj['roles'].dup
    groups += [obj['os']] unless blank?(obj['os'])
    groups + [obj.chef_environment]
  end

  def get_hostname(obj)
    return obj.name if @host_name_attribute == 'name'
    return obj['nagios']['host_name'] unless blank?(obj['nagios']) || blank?(obj['nagios']['host_name'])
    return obj[@host_name_attribute] unless blank?(obj[@host_name_attribute])
    return obj['hostname'] unless blank?(obj['hostname'])
    return obj.name unless blank?(obj.name)
    nil
  end

  def push_node(obj)
    groups = get_groups(obj)
    hostname = get_hostname(obj)
    return nil if hostname.nil?

    host = find(Nagios::Host.new(hostname))
    # TODO: merge the ip_to_monitor funtion into this logic here
    host.address = obj['ipaddress']
    host.import(obj['nagios']) unless obj['nagios'].nil?

    groups.each do |r|
      hg = find(Nagios::Hostgroup.new(r))
      hg.push(host)
      host.push(hg)
    end
  end
  # rubocop:enable MethodLength

  def push_object(obj)
    object = find(obj.class.new(obj.to_s))
    object.merge!(obj)
  end
end
