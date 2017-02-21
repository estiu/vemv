<% module_namespacing do -%>
describe <%= class_name %>Job do

  let(:<%= model_name %>) { FactoryGirl.create(:<%= model_name %>) }
  
  it "works" do
    expect(<%= class_name %>Mailer).to receive(:perform).at_least(1).times.and_call_original
    <%= class_name %>Job.perform_later <%= model_name %>.id
  end
  
end
<% end -%>
