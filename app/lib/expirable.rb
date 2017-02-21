module Expirable
  
  def self.included base
    base.class_eval do
      
      validates :active, inclusion: [true, false]
      validates :active, inclusion: [true], if: :must_be_reviewed?
      
      validate :cannot_become_active_again, if: :persisted?
      
      def cannot_become_active_again
        if active_changed? && active
          errors[:active] << "A space cannot become active again once it has expired."
        end
      end
      
      def self.active
        where(active: true)
      end
      
      def self.expired
        where(active: false)
      end
      
    end
  end
  
end