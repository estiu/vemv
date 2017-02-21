module Kuina
  
  class Time
    
    def self.time_select
      # 0-24 is a bit odd (results in 25 hours total), but it results in a better UX.
      (0..24).map do |n|
        tod = Tod::TimeOfDay.new(n == 24 ? 0 : n)
        [tod.to_s, tod.second_of_day.to_s]
      end
    end
    
  end
  
end