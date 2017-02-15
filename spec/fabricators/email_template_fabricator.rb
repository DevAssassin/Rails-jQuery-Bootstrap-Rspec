Fabricator(:email_template) do
  name "AnEmailTemplate"
  source "foo{{{content}}}bar"
end
