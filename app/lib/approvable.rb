module Approvable
  
  def self.included base
    base.class_eval do
      
      validates :approved_at, inclusion: [nil], if: :rejected_at
      validates :rejected_at, inclusion: [nil], if: :approved_at
      
      validate :approvable_columns_cannot_become_blank
      
      def self.approved
        where.not(approved_at: nil)
      end
      
      def self.rejected
        where.not(rejected_at: nil)
      end
      
      def self.not_approved
        where(approved_at: [nil, false])
      end
      
      def self.not_rejected
        where(rejected_at: [nil, false])
      end
      
      def must_be_reviewed?
        !approved_at && !rejected_at
      end
      
      def became_approved?
        previous_change_blank_to_present :approved_at
      end
      
      def became_rejected?
        previous_change_blank_to_present :rejected_at
      end
      
      def approvable_columns_cannot_become_blank
        %i(approved_at rejected_at).each do |column|
          if previous_change_present_to_blank column
            errors[column] << "#{column} cannot be removed"
          end
        end
      end
  
      {approve!: :approved_at, reject!: :rejected_at}.each do |method, attr|
        define_method method do
          update_attributes!({attr => Time.current})
        end
      end
      
      {approved?: :approved_at, rejected?: :rejected_at}.each do |method, attr|
        define_method method do
          send(attr).present?
        end
      end
      
    end
  end
  
end