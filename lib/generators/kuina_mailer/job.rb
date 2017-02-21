<% module_namespacing do -%>
class <%= class_name %>Job < ApplicationJob
  
  def perform <%= model_name %>_id
    <%= model_name %> = <%= model_name.camelize %>.find <%= model_name %>_id
    <%= class_name %>Mailer.perform(<%= model_name %>).deliver_later
  end
  
end
<% end -%>
