module Rails
  module Generators
    class KuinaMailerGenerator < NamedBase
      source_root File.expand_path("../kuina_mailer", __FILE__)
      
      argument :model_name, default: 'object'
      
      check_class_collision suffix: "Mailer"
      
      def create_mailer_file
        template "mailer.rb", File.join("app/mailers", class_path, "#{file_name}_mailer.rb")
        template "job.rb", File.join("app/jobs", class_path, "#{file_name}_job.rb")
        template "spec.rb", File.join("spec/jobs", class_path, "#{file_name}_job_spec.rb")
        template "preview.rb", File.join("app/mailer_previews", class_path, "#{file_name}_preview.rb")
        template "rich.haml", File.join("app/views/mailers", class_path, "#{file_name}_mailer/perform.haml")
        template "plain.haml", File.join("app/views/mailers", class_path, "#{file_name}_mailer/perform.text.haml")
      end
      
      private
      
      def file_name # :doc:
        @_file_name ||= super.gsub(/_mailer/i, "")
      end
      
      def application_mailer_file_name
        @_application_mailer_file_name ||= if mountable_engine?
          "app/mailers/#{namespaced_path}/application_mailer.rb"
        else
          "app/mailers/application_mailer.rb"
        end
      end
    end
  end
end
