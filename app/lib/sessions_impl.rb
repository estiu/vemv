module SessionsImpl
  
  def self.included base
    base.class_eval do
            
      prepend_before_action :clear

      def clear
        if params[:action] == 'destroy'
          cookies.delete 'remember_user_token'
        end
      end

    end
  end
  
end