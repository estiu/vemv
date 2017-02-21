module Payable
  
  STRIPE_EUR = 'eur'.freeze  
  
  def self.included base
    base.class_eval do
      
      validates :stripe_charge_id, inclusion: [nil], unless: ->(rec){ rec.stripe_charge_id.present? }
      validates :stripe_refund_id, inclusion: [nil], unless: ->(rec){ rec.stripe_refund_id.present? }
      validates :stripe_charged_at, presence: true, if: :stripe_charge_id
      validates :stripe_refunded_at, presence: true, if: :stripe_refund_id
      validates :stripe_charged_at, inclusion: [nil], unless: :stripe_charge_id
      validates :stripe_refunded_at, inclusion: [nil], unless: :stripe_refund_id
      
      before_validation :set_stripe_charged_at
      before_validation :set_stripe_refunded_at
      
      def self.paid
        where.not(stripe_charge_id: nil)
      end
      
      def payable?
        [stripe_charge_id, stripe_refund_id].all? &:blank?
      end
      
      def charged?
        stripe_charge_id.present?
      end
      
      def charge!(token)

        raise "already charged" if charged?

        charge = nil

        charge = Stripe::Charge.create(
          amount: payable_amount_cents,
          currency: STRIPE_EUR,
          source: token,
          description: charge_description
        )
        
        class_name = self.class.to_s.underscore
        
        SafeLogger.info { "Successfully charged #{class_name} with id #{id}. Charge id: #{charge.id}" }

        self.stripe_charge_id = charge.id
        saved = self.save
        unless saved
          SafeLogger.error { "Stripe charge succeeded, but could not update the #{class_name} with id #{self.id}. Errors: #{self.errors.full_messages}" }
        end

        on_charge!

        return true

      rescue Stripe::CardError => e
        SafeLogger.error { e }
        return false
      end
      
      def set_stripe_charged_at
        if change_blank_to_present :stripe_charge_id
          self.stripe_charged_at = Time.current
          self.invoice_year = stripe_charged_at.year
        end
      end
      
      def set_stripe_refunded_at
        if change_blank_to_present :stripe_refund_id
          self.stripe_refunded_at = Time.current
        end
      end
      
    end
  end
  
end