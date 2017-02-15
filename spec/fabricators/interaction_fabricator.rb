Fabricator(:interaction) do
  person { Fabricate(:recruit) }
  user
end

Fabricator(:letter_interaction, :class_name => Interactions::Letter, :from => :interaction) do

end

Fabricator(:comment_interaction, :class_name => Interactions::Comment, :from => :interaction) do

end

Fabricator(:phone_call_interaction, :class_name => Interactions::PhoneCall, :from => :interaction) do
  duration "100"
  status "Completed"
end

Fabricator(:edited_phone_call_interaction, :class_name => Interactions::EditedPhoneCall, :from => :interaction) do
  
end

Fabricator(:place_call_interaction, :class_name => Interactions::PlaceCall, :from => :interaction) do
  duration "0"
  status "Initiated"
  placed true
  force true
end

Fabricator(:visit_interaction, :class_name => Interactions::Visit, :from => :interaction) do
  visit_type 'Official'
end

Fabricator(:contact_interaction, :class_name => Interactions::Contact, :from => :interaction) do
  contact_type 'Contact'
end

Fabricator(:rating_interaction, :class_name => Interactions::Rating, :from => :interaction) do

end

Fabricator(:creation_interaction, :class_name => Interactions::Creation, :from => :interaction) do
  creation_type "Manual"
end

Fabricator(:email_interaction, :class_name => Interactions::Email, :from => :interaction) do
  subject "Hello"
  from_email "foo@example.local"
  to_email "bar@example.local"
end

Fabricator(:donation_interaction, :class_name => Interactions::Donation, :from => :interaction) do
  amount 123.45
end

Fabricator(:sms_interaction, :class_name => Interactions::Sms, :from => :interaction) do
  phone_number '7349614759'
  text 'testsms'
end

Fabricator(:alert_interaction, class_name: Interactions::Alert, from: :interaction) do
end
