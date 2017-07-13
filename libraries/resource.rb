#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: resource
#
# Copyright 2015, Sander Botman
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
  # This class holds all methods with regard to resource options,
  # that are used within nagios configurations.
  #
  class Resource < Nagios::Base
    attr_reader   :key
    attr_accessor :value

    def initialize(key, value = nil)
      @key = key
      @value = value
      super()
    end

    def definition
      if blank?(value)
        "# Skipping #{key} because the value is missing."
      elsif key =~ /^USER([1-9]|[1-9][0-9]|[1-2][0-4][0-9]|25[0-6])$/
        "$#{@key}$=#{@value}"
      else
        "# Skipping #{key} because the it's not valid. Use USER[1-256] as your key."
      end
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Resource.new(name))
    end

    def import(hash)
      update_options(hash)
    end

    def to_s
      key
    end
  end
end
