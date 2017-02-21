module ApplicationRecordImpl
  
  def self.included base
    base.class_eval do
      
      def previous_change_blank_to_present key
        change = previous_changes[key]
        change && change[0].blank? && change[1].present?
      end
      
      def previous_change_present_to_blank key
        change = previous_changes[key]
        change && change[0].present? && change[1].blank?
      end
      
      def change_blank_to_present key
        change = changes[key]
        change && change[0].blank? && change[1].present?
      end
      
      def change_present_to_blank key
        change = changes[key]
        change && change[0].present? && change[1].blank?
      end
      
    end
  end
  
end