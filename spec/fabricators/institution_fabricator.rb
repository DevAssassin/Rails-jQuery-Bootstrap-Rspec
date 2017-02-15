Fabricator(:institution) do
  name "Foo School"

  after_build { |i| i.address = Fabricate.build(:address) }
end

Fabricator(:club, from: :institution, class_name: Club) do
end

Fabricator(:school, from: :institution, class_name: School) do
end

Fabricator(:college, from: :institution, class_name: College) do
end
