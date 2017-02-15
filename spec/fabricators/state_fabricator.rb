Fabricator(:state) do
  name { Fabricate.sequence(:name) { |i| "State #{i}" } }
end

