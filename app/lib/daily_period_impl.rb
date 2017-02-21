module DailyPeriodImpl
  
  def self.included base
    base.class_eval do
      
      belongs_to :reservable_by_days, polymorphic: true, inverse_of: :daily_periods

      delegate :space, to: :reservable_by_days

      validates :start_date, presence: true
      validates :end_date, presence: true

      validate :start_date_value, on: :create
      validate :end_date_greater_than_start_date

      def self.future
        select &:in_future_time? # XXX perform at sql level
      end

      def reservable
        reservable_by_days
      end

      def rate_units
        if [self.end_date, self.start_date].all? &:present?
          (self.end_date - self.start_date) + 1
        else
          0
        end
      end

      def in_future_time?
        Time.use_zone(space.timezone) do
          start_date >= Time.current.to_date
        end
      end

      def overlaps_with? other
        if other.is_a?(DailyPeriod)
          ((self.start_date..self.end_date).overlaps?(other.start_date..other.end_date))
        elsif other.is_a?(HourlyPeriod)
          (self.start_date..self.end_date).include?(other.date)
        else
          fail
        end
      end

      def start_date_value
        # XXX Time.current should take space's timezone instead of config.time_zone
        if start_date.is_a?(Date)
          unless (Time.current.to_date - start_date).to_i <= 0
            errors[:date] << "Must be today or in the future"
          end
        end
      end

      def end_date_greater_than_start_date
        if [start_date, end_date].all?{|a| a.is_a?(Date) }
          if end_date < start_date
            errors[:end_date] << "End date must be after or equal to the start date"
          end
        end
      end

      def number_of_days
        (start_date - end_date).to_i.abs + 1
      end

      def to_s
        diff = number_of_days
        if diff == 1
          I18n.t!('daily_period.present_periods_single', date: start_date)
        else
          I18n.t!('daily_period.present_periods_multiple', start_date: start_date, end_date: end_date, days: diff)
        end
      end

      def to_calendar_entry
        CalendarEntry.new parent: self, start_time: start_date, end_time: end_date
      end

      def min_date
        start_date
      end

      def max_date
        end_date
      end
      
    end
  end
  
end