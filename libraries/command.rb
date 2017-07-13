#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: command
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
  # This class holds all methods with regard to command options,
  # that are used within nagios configurations.
  #
  class Command < Nagios::Base
    attr_reader   :command_name,
                  :timeout
    attr_accessor :command_line

    def initialize(command_name)
      cmd = command_name.split('!')
      @command_name = cmd.shift
      @timeout = nil
      super()
    end

    def definition
      if blank?(command_line)
        "# Skipping #{command_name} because command_line is missing."
      else
        get_definition(configured_options, 'command')
      end
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Command.new(name))
    end

    def command_line=(command_line)
      param = command_timeout(command_line)
      @command_line = if @timeout.nil?
                        command_line
                      elsif param.nil?
                        command_line + " -t #{@timeout}"
                      else
                        command_line.gsub(param, "-t #{@timeout}")
                      end
      @command_line
    end

    def import(hash)
      @command_line = hash if hash.class == String
      hash['command_line'] == hash['command'] unless hash['command'].nil?
      update_options(hash)
    end

    def to_s
      command_name
    end

    private

    def command_timeout(command_line)
      if command_line =~ /(-t *?(\d+))/
        timeout = Regexp.last_match[2].to_i + 5
        @timeout = timeout if @timeout.nil? || timeout > @timeout
        return Regexp.last_match[1]
      end
      nil
    end

    def config_options
      {
        'command_name' => 'command_name',
        'command_line' => 'command_line',
      }
    end
  end
end
