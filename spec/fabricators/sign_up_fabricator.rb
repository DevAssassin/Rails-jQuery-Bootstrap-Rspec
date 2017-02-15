Fabricator(:SignUp) do
  first_name "Testuser"
  last_name "Testerson"
  email { Fabricate.sequence(:email) { |i| "user#{i}@scoutforce.local" } }
  college { Fabricate(:college) }
  plan "single"
  sport_name "Baseball"
end
