Fabricator(:coach) do
  first_name { Fabricate.sequence(:first_name) { |i| "Coach#{i}" } }
  last_name { Fabricate.sequence(:last_name) { |i| "Jones#{i}" } }
  cell_phone "734-555-1234"
  coach true
end

Fabricator(:staff, :class_name => "Coach") do
  first_name { Fabricate.sequence(:first_name) { |i| "Staff#{i}" } }
  last_name { Fabricate.sequence(:last_name) { |i| "Smith#{i}" } }
  cell_phone "734-555-1234"
  coach false
end
