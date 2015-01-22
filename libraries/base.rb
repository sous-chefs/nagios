#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Library:: base
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
# rubocop:disable ClassLength
class Nagios
  # This class it the base for all other Nagios classes.
  # It provides common methods to prevent code duplication.
  class Base
    attr_accessor :register,
                  :name,
                  :use

    def merge!(obj)
      merge_members(obj)
      merge_attributes(obj)
    end

    def merge_members!(obj)
      merge_members(obj)
    end

    def register
      if blank?(@name)
        return @register
      else
        return 0
      end
    end

    def register=(arg)
      @register = check_bool(arg)
    end

    def use
      default_template
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
        false
      end
      false
    end

    def check_bool(arg)
      if arg.class == TrueClass
        return 1
      elsif arg.to_s =~ /^y|yes|true|on|1$/i
        return 1
      else
        return 0
      end
    end

    def check_integer(int)
      return int.to_i if int.class == String
      int
    end

    def check_state_option(arg, options, entry)
      if options.include?(arg)
        Chef::Log.debug("#{self.class} #{id} adding option #{arg} for entry #{entry}")
      else
        Chef::Log.fail("#{self.class} #{id} object error: Unknown option #{arg} for entry #{entry}")
        fail
      end
    end

    def check_state_options(arg, options, entry)
      if arg.class == String
        check_state_options(arg.split(','), options, entry)
      elsif arg.class == Array
        arg.each { |a| check_state_option(a.strip, options, entry) }.join(',')
      else
        arg
      end
    end

    def check_use_and_name(default)
      return nil if default.nil?
      if to_s == default.to_s
        return nil
      else
        return default
      end
    end

    # rubocop:disable MethodLength
    def default_template
      return @use unless @use.nil?
      return nil if @name
      case self
      when Nagios::Command
        check_use_and_name(Nagios.instance.default_command)
      when Nagios::Contactgroup
        check_use_and_name(Nagios.instance.default_contactgroup)
      when Nagios::Contact
        check_use_and_name(Nagios.instance.default_contact)
      when Nagios::Hostgroup
        check_use_and_name(Nagios.instance.default_hostgroup)
      when Nagios::Host
        check_use_and_name(Nagios.instance.default_host)
      when Nagios::Servicegroup
        check_use_and_name(Nagios.instance.default_servicegroup)
      when Nagios::Service
        check_use_and_name(Nagios.instance.default_service)
      when Nagios::Timeperiod
        check_use_and_name(Nagios.instance.default_timeperiod)
      end
    end
    # rubocop:enable MethodLength

    def get_commands(obj)
      obj.map(&:id).join(',')
    end

    def configured_option(method)
      value = send(method)
      return nil if blank?(value)
      if value.class == Array
        value.join(',')
      else
        value
      end
    end

    def configured_options
      configured = {}
      config_options.each do |m, o|
        next if o.nil?
        value = configured_option(m)
        next if value.nil?
        configured[o] = value
      end
      configured
    end

    def get_definition(options, group)
      d = ["define #{group} {"]
      d += get_definition_options(options)
      d += ['}']
      d.join("\n")
    end

    def get_definition_options(options)
      r = []
      longest = get_longest_option(options)
      options.each do |k, v|
        k = k.to_s
        v = v.to_s
        diff = longest - k.length
        r.push(k.rjust(k.length + 2) + v.rjust(v.length + diff + 2))
      end
      r
    end

    def get_longest_option(options)
      longest = 0
      options.each do |k, _|
        longest = k.length if longest < k.length
      end
      longest
    end

    # rubocop:disable MethodLength
    def get_members(option)
      members = []
      case option
      when String
        members = option.split(',')
      when Array
        members = option
      else
        Chef::Log.fail("Nagios fail: Use an Array or comma seperated String for option: #{option} within #{self.class}")
        fail
      end
      members
    end
    # rubocop:enable MethodLength

    def get_timeperiod(obj)
      return nil if obj.nil?
      return obj.id if obj.class == Nagios::Timeperiod
      obj
    end

    def merge_attributes(obj)
      config_options.each do |m, _|
        n = obj.send(m)
        next if n.nil?
        m += '='
        send(m, n) if self.respond_to?(m)
      end
    end

    def merge_members(obj)
      Chef::Log.debug("Nagios debug: The method merge_members is not supported by #{obj.class}")
    end

    def push_object(obj, hash)
      if hash[obj.id].nil?
        hash[obj.id] = obj
      else
        Chef::Log.debug("Nagios debug: #{self.class} already contains #{obj.class} with id: #{obj.id}")
      end
    end

    # rubocop:disable MethodLength
    def notification_commands(obj)
      commands = []
      case obj
      when Nagios::Command
        commands.push(obj)
      when Array
        obj.each { |o| commands += notification_commands(o) }
      when String
        obj.split(',').each do |o|
          c = Nagios::Command.new(o.strip)
          n = Nagios.instance.find(c)
          if c == n
            Chef::Log.fail("#{self.class} fail: Cannot find command #{o} please define it first.")
            fail
          else
            commands.push(n)
          end
        end
      end
      commands
    end
    # rubocop:enable MethodLength

    def hostname(name)
      if Nagios.instance.normalize_hostname
        name.downcase
      else
        name
      end
    end

    def update_options(hash)
      # We can only merge hash or databagitem's, so lets check for them.
      return nil if blank?(hash)
      return nil unless hash.class == Hash || hash.class == Chef::DataBagItem
      hash.each do |k, v|
        m = k + '='
        send(m, v) if self.respond_to?(m)
      end
    end

    def update_members(hash, option, object, remote = false)
      return if blank?(hash) || hash[option].nil?
      get_members(hash[option]).each do |member|
        n = Nagios.instance.find(object.new(member))
        push(n)
        n.push(self) if remote
      end
    end
  end
end
