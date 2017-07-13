#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook:: nagios
# Library:: timeperiod
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
  #  This class holds all methods with regard to timeperiodentries,
  #  that are used within the timeperiod nagios configurations.
  #
  class Timeperiodentry
    attr_reader :moment,
                :period

    def initialize(moment, period)
      @moment = moment
      @period = check_period(period)
    end

    def to_s
      moment
    end

    private

    def check_period(period)
      return period if period =~ /^(([01]?[0-9]|2[0-3])\:[0-5][0-9]-([01]?[0-9]|2[0-4])\:[0-5][0-9],?)*$/
      nil
    end
  end

  #
  # This class holds all methods with regard to timeperiod options,
  # that are used within nagios configurations.
  #
  class Timeperiod < Nagios::Base
    attr_reader   :timeperiod_name

    attr_accessor :alias,
                  :periods,
                  :exclude

    def initialize(timeperiod_name)
      @timeperiod_name = timeperiod_name
      @periods = {}
      @exclude = {}
      super()
    end

    def self.create(name)
      Nagios.instance.find(Nagios::Timeperiod.new(name))
    end

    def definition
      configured = configured_options
      periods.values.each { |v| configured[v.moment] = v.period }
      get_definition(configured, 'timeperiod')
    end

    # exclude
    # This directive is used to specify the short names of other timeperiod definitions
    # whose time ranges should be excluded from this timeperiod.
    # Multiple timeperiod names should be separated with a comma.

    def exclude
      @exclude.values.map(&:to_s).sort.join(',')
    end

    def import(hash)
      update_options(hash)
      if hash['times'].respond_to?('each_pair')
        hash['times'].each { |k, v| push(Nagios::Timeperiodentry.new(k, v)) }
      end
      update_members(hash, 'exclude', Nagios::Timeperiod)
    end

    def push(obj)
      case obj
      when Nagios::Timeperiod
        push_object(obj, @exclude)
      when Nagios::Timeperiodentry
        push_object(obj, @periods) unless obj.period.nil?
      end
    end

    def pop(obj)
      return if obj == self
      case obj
      when Nagios::Timeperiod
        if @exclude.keys?(obj.to_s)
          pop_object(obj, @exclude)
          pop(self, obj)
        end
      when Nagios::Timeperiodentry
        if @periods.keys?(obj.to_s)
          pop_object(obj, @periods)
          pop(self, obj)
        end
      end
    end
    # rubocop:enable MethodLength

    def to_s
      timeperiod_name
    end

    # [weekday]
    # The weekday directives ("sunday" through "saturday")are comma-delimited
    # lists of time ranges that are "valid" times for a particular day of the week.
    # Notice that there are seven different days for which you can define time
    # ranges (Sunday through Saturday). Each time range is in the form of
    # HH:MM-HH:MM, where hours are specified on a 24 hour clock.
    # For example, 00:15-24:00 means 12:15am in the morning for this day until
    # 12:00am midnight (a 23 hour, 45 minute total time range).
    # If you wish to exclude an entire day from the timeperiod, simply do not include
    # it in the timeperiod definition.

    # [exception]
    # You can specify several different types of exceptions to the standard rotating
    # weekday schedule. Exceptions can take a number of different forms including single
    # days of a specific or generic month, single weekdays in a month, or single calendar
    # dates. You can also specify a range of days/dates and even specify skip intervals
    # to obtain functionality described by "every 3 days between these dates".
    # Rather than list all the possible formats for exception strings, I'll let you look
    # at the example timeperiod definitions above to see what's possible.
    # Weekdays and different types of exceptions all have different levels of precedence,
    # so its important to understand how they can affect each other.

    private

    def config_options
      {
        'timeperiod_name' => 'timeperiod_name',
        'alias'           => 'alias',
        'exclude'         => 'exclude',
      }
    end

    def merge_members(obj)
      obj.periods.each { |m| push(m) }
      obj.exclude.each { |m| push(m) }
    end
  end
end
