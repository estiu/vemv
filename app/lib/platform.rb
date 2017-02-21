require 'mail'

class Platform
  
  class << self
    
    def name
      "Sharing Kitchen"
    end
    
    def telephone
      "+34 644 227 867"
    end
    
    def address
      "Carrer del Dos de Maig, 215. 08013 Barcelona (ES)"
    end
    
    def email
      Mail::Address.new('info@sharing-kitchen.com').tap{|address| address.display_name = name }.format
    end
    
    def notifications_origin_email
      email
    end
    
    def notifications_destination_email
      email
    end
    
    def city
      "Barcelona"
    end
    
  end
  
end