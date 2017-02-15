Fabricator(:user) do
  first_name "Testuser"
  last_name "Testerson"
  email { Fabricate.sequence(:email) { |i| "user#{i}@scoutforce.local" } }
  password "testtest"
  email_signature "With Regards, C.User"
  twilio_callerid_sid = "123abc"
end

Fabricator(:program_user, :from => :user) do
  after_create { |u| u.programs << Fabricate(:program) }
end

Fabricator(:admin, :from => :program_user) do
  first_name "Admin"
  last_name "User"
  email "admin@scoutforce.local"
  superuser true
end
