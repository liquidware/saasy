# -*- encoding : utf-8 -*-
module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Date #:nodoc:
      # Enables the use of time calculations within Time itself
      module Calculations
        def self.included(base) #:nodoc:
          base.extend ClassMethods

          base.instance_eval do
            alias_method :plus_without_duration, :+
            alias_method :+, :plus_with_duration

            alias_method :minus_without_duration, :-
            alias_method :-, :minus_with_duration
          end
        end

        module ClassMethods
          # Returns a new Date representing the date 1 day ago (i.e. yesterday's date).
          def yesterday
            ::Date.today.yesterday
          end

          # Returns a new Date representing the date 1 day after today (i.e. tomorrow's date).
          def tomorrow
            ::Date.today.tomorrow
          end

          # Returns Time.zone.today when config.time_zone is set, otherwise just returns Date.today.
          def current
            ::Time.zone_default ? ::Time.zone.today : ::Date.today
          end
        end

        # Tells whether the Date object's date lies in the past
        def past?
          self < ::Date.current
        end

        # Tells whether the Date object's date is today
        def today?
          self.to_date == ::Date.current # we need the to_date because of DateTime
        end

        # Tells whether the Date object's date lies in the future
        def future?
          self > ::Date.current
        end

        # Converts Date to a Time (or DateTime if necessary) with the time portion set to the beginning of the day (0:00)
        # and then subtracts the specified number of seconds
        def ago(seconds)
          to_time.since(-seconds)
        end

        # Converts Date to a Time (or DateTime if necessary) with the time portion set to the beginning of the day (0:00)
        # and then adds the specified number of seconds
        def since(seconds)
          to_time.since(seconds)
        end
        alias :in :since

        # Converts Date to a Time (or DateTime if necessary) with the time portion set to the beginning of the day (0:00)
        def beginning_of_day
          to_time
        end
        alias :midnight :beginning_of_day
        alias :at_midnight :beginning_of_day
        alias :at_beginning_of_day :beginning_of_day

        # Converts Date to a Time (or DateTime if necessary) with the time portion set to the end of the day (23:59:59)
        def end_of_day
          to_time.end_of_day
        end

        def plus_with_duration(other) #:nodoc:
          if ActiveSupport::Duration === other
            other.since(self)
          else
            plus_without_duration(other)
          end
        end

        def minus_with_duration(other) #:nodoc:
          if ActiveSupport::Duration === other
            plus_with_duration(-other)
          else
            minus_without_duration(other)
          end
        end

        # Provides precise Date calculations for years, months, and days.  The +options+ parameter takes a hash with
        # any of these keys: <tt>:years</tt>, <tt>:months</tt>, <tt>:weeks</tt>, <tt>:days</tt>.
        def advance(options)
          d = self
          d = d >> options.delete(:years) * 12 if options[:years]
          d = d >> options.delete(:months)     if options[:months]
          d = d +  options.delete(:weeks) * 7  if options[:weeks]
          d = d +  options.delete(:days)       if options[:days]
          d
        end

        # Returns a new Date where one or more of the elements have been changed according to the +options+ parameter.
        #
        # Examples:
        #
        #   Date.new(2007, 5, 12).change(:day => 1)                  # => Date.new(2007, 5, 1)
        #   Date.new(2007, 5, 12).change(:year => 2005, :month => 1) # => Date.new(2005, 1, 12)
        def change(options)
          ::Date.new(
            options[:year]  || self.year,
            options[:month] || self.month,
            options[:day]   || self.day
          )
        end

        # Returns a new Date/DateTime representing the time a number of specified months ago
        def months_ago(months)
          advance(:months => -months)
        end

        # Returns a new Date/DateTime representing the time a number of specified months in the future
        def months_since(months)
          advance(:months => months)
        end

        # Returns a new Date/DateTime representing the time a number of specified years ago
        def years_ago(years)
          advance(:years => -years)
        end

        # Returns a new Date/DateTime representing the time a number of specified years in the future
        def years_since(years)
          advance(:years => years)
        end

        # Short-hand for years_ago(1)
        def last_year
          years_ago(1)
        end

        # Short-hand for years_since(1)
        def next_year
          years_since(1)
        end

        # Short-hand for months_ago(1)
        def last_month
          months_ago(1)
        end

        # Short-hand for months_since(1)
        def next_month
          months_since(1)
        end

        # Returns a new Date/DateTime representing the "start" of this week (i.e, Monday; DateTime objects will have time set to 0:00)
        def beginning_of_week
          days_to_monday = self.wday!=0 ? self.wday-1 : 6
          result = self - days_to_monday
          self.acts_like?(:time) ? result.midnight : result
        end
        alias :monday :beginning_of_week
        alias :at_beginning_of_week :beginning_of_week

        # Returns a new Date/DateTime representing the end of this week (Sunday, DateTime objects will have time set to 23:59:59)
        def end_of_week
          days_to_sunday = self.wday!=0 ? 7-self.wday : 0
          result = self + days_to_sunday.days
          self.acts_like?(:time) ? result.end_of_day : result
        end
        alias :at_end_of_week :end_of_week

        # Returns a new Date/DateTime representing the start of the given day in next week (default is Monday).
        def next_week(day = :monday)
          days_into_week = { :monday => 0, :tuesday => 1, :wednesday => 2, :thursday => 3, :friday => 4, :saturday => 5, :sunday => 6}
          result = (self + 7).beginning_of_week + days_into_week[day]
          self.acts_like?(:time) ? result.change(:hour => 0) : result
        end

        # Returns a new ; DateTime objects will have time set to 0:00DateTime representing the start of the month (1st of the month; DateTime objects will have time set to 0:00)
        def beginning_of_month
          self.acts_like?(:time) ? change(:day => 1,:hour => 0, :min => 0, :sec => 0) : change(:day => 1)
        end
        alias :at_beginning_of_month :beginning_of_month

        # Returns a new Date/DateTime representing the end of the month (last day of the month; DateTime objects will have time set to 0:00)
        def end_of_month
          last_day = ::Time.days_in_month( self.month, self.year )
          self.acts_like?(:time) ? change(:day => last_day, :hour => 23, :min => 59, :sec => 59) : change(:day => last_day)
        end
        alias :at_end_of_month :end_of_month

        # Returns a new Date/DateTime representing the start of the quarter (1st of january, april, july, october; DateTime objects will have time set to 0:00)
        def beginning_of_quarter
          beginning_of_month.change(:month => [10, 7, 4, 1].detect { |m| m <= self.month })
        end
        alias :at_beginning_of_quarter :beginning_of_quarter

        # Returns a new Date/DateTime representing the end of the quarter (last day of march, june, september, december; DateTime objects will have time set to 23:59:59)
        def end_of_quarter
          beginning_of_month.change(:month => [3, 6, 9, 12].detect { |m| m >= self.month }).end_of_month
        end
        alias :at_end_of_quarter :end_of_quarter

        # Returns a new Date/DateTime representing the start of the year (1st of january; DateTime objects will have time set to 0:00)
        def beginning_of_year
          self.acts_like?(:time) ? change(:month => 1, :day => 1, :hour => 0, :min => 0, :sec => 0) : change(:month => 1, :day => 1)
        end
        alias :at_beginning_of_year :beginning_of_year

        # Returns a new Time representing the end of the year (31st of december; DateTime objects will have time set to 23:59:59)
        def end_of_year
          self.acts_like?(:time) ? change(:month => 12,:day => 31,:hour => 23, :min => 59, :sec => 59) : change(:month => 12, :day => 31)
        end
        alias :at_end_of_year :end_of_year

        # Convenience method which returns a new Date/DateTime representing the time 1 day ago
        def yesterday
          self - 1
        end

        # Convenience method which returns a new Date/DateTime representing the time 1 day since the instance time
        def tomorrow
          self + 1
        end
      end
    end
  end
end
