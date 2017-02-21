<% module_namespacing do -%>
class <%= class_name %>Mailer < ApplicationMailer

  def perform <%= model_name %>
    @<%= model_name %> = <%= model_name %>
    @p1 = t('.p1')

    mail(to: <%= model_name %>.email, subject: t('.subject'))
  end

end
<% end -%>
