<% module_namespacing do -%>
class <%= class_name %>Preview < ActionMailer::Preview
  
  def perform
    <%= model_name %> = FactoryGirl.create :<%= model_name %>
    <%= class_name %>Mailer.perform(<%= model_name %>)
  end

end
<% end -%>
