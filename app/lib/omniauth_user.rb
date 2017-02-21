class OmniauthUser
  
  # This method returns a new (unsaved) or existing (updated but unsaved) User, given its email and uid.
  # Its goals are:
  # a) create a new User from scratch, given its FB credentials
  # b) return an existing User given its FB credentials, if the user signed up already via email/password.
  def self.from_facebook email, first_name, last_name, fb_attrs
    
    uid = fb_attrs[:uid]
    user = User.find_by(email: email, uid: uid, provider: 'facebook') || User.find_by(email: email)
    
    unless user
      
      user = User.where(uid: uid, provider: 'facebook', signed_up_via_facebook: true).first_or_initialize
      
      unless user.id
        user.confirmed_at = Time.current
        user.password = user.password_confirmation = SecureRandom.hex(32) # securely avoid validation error
      end
      
    end
    
    if user.signed_up_via_facebook # important! only update email (and less importantly, the first_name/last_name) if the user didn't sign up via email/password.
      user.consumer ||= Consumer.new
      user.email = email
      user.skip_reconfirmation! # else email becomes unconfirmed_email
      user.consumer.first_name = first_name
      user.consumer.last_name = last_name
    end
    
    user.assign_attributes(fb_attrs)

    user
    
  end
  
end