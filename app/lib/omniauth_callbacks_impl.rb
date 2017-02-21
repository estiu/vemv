module OmniauthCallbacksImpl
  
  def self.included base
    base.class_eval do
            
      def facebook
        
        success = true
        
        email, first_name, last_name = auth_hash.fetch(:info).values_at(:email, :first_name, :last_name)
        
        fb_attrs = { # a whitelist of attributes to be assigned. do not include email/first_name/last_name - they have to be handled in a separate way.
          uid: auth_hash[:uid],
          provider: auth_hash[:provider]
        }
        
        if current_user 
          
          # user already signed in - he has hit this endpoint for whatever reason (it should be basically impossible for a well behaved user).
          # this branch avoids calling OmniauthUser.from_facebook (extra queries)
          user = current_user
          user.update_attributes(fb_attrs) # ignore validation errors - the update doesn't matter a lot
          success = true
          
        else
          
          user = OmniauthUser.from_facebook email, first_name, last_name, fb_attrs
          
          if user.save || user.id # user.id: ignore validation errors for existing users.
            success = true
          else
            SafeLogger.error { user.errors.full_messages }
            session["devise.user_attributes"] = user.attributes # for showing error messages to the user
            success = false
          end
        end
        
        if success
          flash[:success] = I18n.t('application.welcome')
          sign_in_and_redirect user
        else
          unless email.present?
            flash[:notice] = I18n.t('application.fb_permissions_error')
          end
          redirect_to new_user_registration_path
        end
        
      end

      protected

      def auth_hash
        request.env['omniauth.auth']
      end

    end
  end
  
end