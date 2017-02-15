Fabricator(:email) do
end

Fabricator(:single_email, :from => :email) do
  recipients {[Fabricate(:baseball_recruit)]}
  from {Fabricate(:user)}
  subject "Test Subject"
  body "<p>html body</p>"
  cc "cc@example.local"
  bcc "bcc@example.local"
end

