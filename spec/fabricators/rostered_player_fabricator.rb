Fabricator(:rostered_player) do
  first_name { Fabricate.sequence(:first_name) { |i| "Player#{i}" } }
  last_name { Fabricate.sequence(:last_name) { |i| "Robinson#{i}" } }
  cell_phone "734-555-1234"
end
