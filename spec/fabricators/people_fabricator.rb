Fabricator(:person) do
  first_name { Fabricate.sequence(:first_name) { |i| "Person#{i}" } }
  last_name { Fabricate.sequence(:last_name) { |i| "Smith#{i}" } }
end

Fabricator(:donor, :from => :person) do
  donor true
end

Fabricator(:alumnus, :from => :person) do
  alumnus true
end

Fabricator(:parent, :from => :person) do
  parent true
end

Fabricator(:person_with_email, :from => :person) do
  email { Fabricate.sequence(:email) { |i| "personsmith#{i}@example.com" } }
end
