module Invoiceable
  
  def self.included base
    base.class_eval do
      
      validates :invoice_number, inclusion: [nil], unless: :charged?
      validates :invoice_number, presence: true, if: :charged?
      validates :invoice_number, uniqueness: {scope: :invoice_year}, allow_nil: true
      validates :invoice_year, inclusion: [nil], unless: :stripe_charged_at
      validates :invoice_year, presence: true, if: :stripe_charged_at
      
      validate :invoice_year_equals_stripe_charged_at_year, if: :stripe_charged_at

      before_validation :generate_invoice_number, if: :became_charged?

      def became_charged?
        change_blank_to_present(:stripe_charged_at)
      end
      
      def invoice_year_equals_stripe_charged_at_year
        unless invoice_year == stripe_charged_at.year
          errors[:invoice_year] << "Must equal stripe_charged_at.year"
        end
      end
      
      def generate_invoice_number
        latest = SpaceOrder.where(invoice_year: self.invoice_year).maximum(:invoice_number)
        self.invoice_number = (latest || 0) + 1
      end
      
      def present_invoice_number
        "SK-#{invoice_year}-#{invoice_number.to_s.rjust(4, '0')}"
      end
      
    end
  end
  
end