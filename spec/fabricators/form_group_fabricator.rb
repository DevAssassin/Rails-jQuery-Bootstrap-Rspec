Fabricator(:form_group) do
  name "Test form group"
  forms { |f| [Fabricate(:form, :account => f.account), Fabricate(:other_form, :account => f.account)] }
end

Fabricator(:other_form_group, :from => :form_group) do
  name "Test 3-part form group"
  forms { |f| [Fabricate(:form, :account => f.account), Fabricate(:other_form, :account => f.account), Fabricate(:form, :account => f.account)] }
end

Fabricator(:form_group_with_completed_forms, :from => :form_group) do
  program!
  forms { |f| [ Fabricate(:filled_in_form) ] }
  completed_forms(:count => 3) { |fg,i| Fabricate(:completed_form, :form_group => fg, :form => fg.forms.first) }
end
