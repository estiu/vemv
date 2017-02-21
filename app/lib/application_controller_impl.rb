module ApplicationControllerImpl
  
  def self.included base
    base.class_eval do
            
      include Pundit

      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActionController::ParameterMissing, with: :param_required

      def handle_not_found
        SafeLogger.error(rollbar: false) { "404 - not found: #{logging_info_for_error_handling}" }
        render file: Rails.root.join('public', '404.html'), layout: false, status: 404
      end

      def user_not_authorized *e
        logger.info e if development_or_test?
        flash[:alert] = t('application.forbidden')
        handle_unauthorized
      end

      def param_required *e
        logger.info e if development_or_test?
        flash[:alert] = t('application.param_required')
        handle_unauthorized
      end

      def handle_unauthorized
        if request.xhr?
          render json: flash_json, status: 403
        else
          redirect_to(root_path)
        end
      end

      helper_method :date_format
      def date_format
        Date::DATE_FORMATS[:default]
      end

      helper_method :datetime_format
      def datetime_format
        Time::DATE_FORMATS[:default]
      end

      private

      def logging_info_for_error_handling
        "#{request.try(:fullpath)} - current_user.id: #{current_user.try(:id) || 'nil'}"
      end

    end
  end
  
end