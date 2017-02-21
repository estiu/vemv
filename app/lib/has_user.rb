module HasUser
  
  def self.included base
    base.class_eval do
        
      has_one :user
      delegate :email, to: :user, prefix: true, allow_nil: true
    
    end
  end
  
end