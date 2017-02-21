module HourlyPeriodImpl
  
  def self.included base
    base.class_eval do
      
      belongs_to :reservable_by_hours, polymorphic: true, inverse_of: :hourly_periods
      
      delegate :space, to: :reservable_by_hours
      
      attr_accessor :start_time_seconds, :end_time_seconds
      serialize :start_time
      serialize :end_time
      
      validates :date, presence: true
      validates :start_time, presence: true
      validates :end_time, presence: true
      
      validate :date_value, on: :create
      validate :future_time_validation, on: :create
      validate :end_time_greater_than_start_time
      validate :time_column_types
      
      def self.future
        select &:in_future_time? # XXX perform at sql level
      end
      
      def reservable
        reservable_by_hours
      end
      
      def rate_units
        if [self.end_time, self.start_time].all?(&:present?)
          (self.end_time - self.start_time).hour
        else
          0
        end
      end
      
      def in_future_time?
        return nil unless [space, start_time, end_time].all?(&:present?)
        Time.use_zone(space.timezone) do
          reference = Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.minute)
          (reference - Time.current).seconds >= 5.minutes
        end
      end
      
      def overlaps_with? other
        if other.is_a?(DailyPeriod)
          other.overlaps_with?(self) # the 'primary' definition of `overlaps_with?` lives in HourlyPeriod. Here we just forward the call.
        elsif other.is_a?(HourlyPeriod)
          (self.date == other.date) && ((Tod::Shift.new self.start_time, self.end_time).overlaps?(Tod::Shift.new other.start_time, other.end_time))
        end
      end
      
      def future_time_validation
        if in_future_time? == false # ignore nil values
          errors[:end_time_seconds] << I18n.t('hourly_period.future_time_validation')
        end
      end
      
      def time_column_types
        %i(start_time end_time).each do |column|
          unless send(column).is_a?(Tod::TimeOfDay)
            errors[column] << "Must be a Tod::TimeOfDay"
          end
        end
      end
      
      def date_value
        # XXX Time.current should take space's timezone instead of config.time_zone
        if date.is_a?(Date)
          unless (Time.current.to_date - date).to_i <= 0
            errors[:date] << "The date must be today or in the future"
          end
        end
      end
      
      def end_time_greater_than_start_time
        return unless [start_time, end_time].all?(&:present?)
        if start_time >= end_time
          unless end_time.second_of_day.zero? # edge case: a 19:00 to 0:00 event
            errors[:start_time] << "Start time must be prior to the end time"
          end
        end
      end
      
      def start_time_seconds= v
        self.start_time = Tod::TimeOfDay.from_second_of_day v.to_i
      end
      
      def end_time_seconds= v
        self.end_time = Tod::TimeOfDay.from_second_of_day v.to_i
      end
      
      def start_time_seconds
        if self.start_time.present?
          self.start_time.second_of_day
        else
          @start_time_seconds
        end
      end
      
      def end_time_seconds
        if self.end_time.present?
          self.end_time.second_of_day
        else
          @end_time_seconds
        end
      end
      
      def to_s
        I18n.t!('hourly_period.present_periods', date: date, start_time: start_time, end_time: end_time)
      end
      
      def to_calendar_entry
        CalendarEntry.new parent: self, start_time: Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.minute), end_time: Time.zone.local(date.year, date.month, date.day, end_time.hour, end_time.minute)
      end
      
      def min_date
        date
      end
      
      def max_date
        date
      end
      
    end
  end
  
end