class CalendarEntry
  
  include ActiveModel::Model
  
  attr_accessor :start_time, :end_time, :parent
  
  delegate :to_s, to: :parent
  
end