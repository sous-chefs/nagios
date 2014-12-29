#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Library:: nagios_command
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
  class Command < Nagios::Base
    attr_reader   :command_name
    attr_accessor :command_line
 
    def initialize(command_name)
      @command_name = command_name
    end

    def definition
      configured = get_configured_options
      (['define command{'] + get_definition_options(configured) + ['}']).join("\n")
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Command.new(name))
    end

    def id
      self.command_name
    end

    def import_hash(hash)
      update_options(hash)
    end 

    def to_s
      self.command_name
    end
  
    private

    def config_options
    { 
      'command_name' => 'command_name',
      'command_line' => 'command_line'
    }
    end
 
  end
end
