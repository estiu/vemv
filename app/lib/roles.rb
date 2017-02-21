class Roles
  
  def self.all
    %w(consumer admin keeper)
  end
  
  self.all.each do |role|
    define_singleton_method role do
      role
    end
  end
  
  def self.with_associated_models
    all - [admin]
  end
  
end