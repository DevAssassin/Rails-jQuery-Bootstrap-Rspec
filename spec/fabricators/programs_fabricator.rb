Fabricator(:program) do
  sport_class_name "Baseball"
  name { |program| "Test #{program.sport_class_name} Program" }
  account!
end

Fabricator(:baseball_program, :from => :program) do

end

Fabricator(:swimming_program, :from => :program) do
  sport_class_name "Swimming"
end

Fabricator(:sales_program, :from => :program) do
  sport_class_name "Sales"
end

Fabricator(:soccer_program, :from => :program) do
  sport_class_name "Soccer"
end

Fabricator(:basketball_program, :from => :program) do
  sport_class_name "Basketball"
end

Fabricator(:track_and_field_program, :from => :program) do
  sport_class_name "TrackAndField"
end

Fabricator(:cross_country_program, :from => :program) do
  sport_class_name "CrossCountry"
end

Fabricator(:football_program, :from => :program) do
  sport_class_name "Football"
end

Fabricator(:softball_program, :from => :program) do
  sport_class_name "Softball"
end

Fabricator(:golf_program, :from => :program) do
  sport_class_name "Golf"
end

Fabricator(:tennis_program, :from => :program) do
  sport_class_name "Tennis"
end

Fabricator(:volleyball_program, :from => :program) do
  sport_class_name "Volleyball"
end

Fabricator(:bowling_program, :from => :program) do
  sport_class_name "Bowling"
end

Fabricator(:lacrosse_program, :from => :program) do
  sport_class_name "Lacrosse"
end

Fabricator(:wrestling_program, :from => :program) do
  sport_class_name "Wrestling"
end

Fabricator(:gymnastics_program, :from => :program) do
  sport_class_name "Gymnastics"
end

Fabricator(:field_hockey_program, :from => :program) do
  sport_class_name "FieldHockey"
end

Fabricator(:equestrian_program, :from => :program) do
  sport_class_name "Equestrian"
end

Fabricator(:ice_hockey_program, :from => :program) do
  sport_class_name "IceHockey"
end

Fabricator(:cheer_program, :from => :program) do
  sport_class_name "Cheer"
end

Fabricator(:dance_program, :from => :program) do
  sport_class_name "Dance"
end

# Custom field fabricators

Fabricator(:custom_field, :class_name => Programs::CustomField) do
  program
  section 'athletic'
  label { Fabricate.sequence(:last_name) { |i| "Test Field #{i}" } }
  visible true
end

Fabricator(:program_with_custom_fields, :from => :program) do
  custom_fields do |program|
    %w(athletic academic personal).map do |section|
      Fabricate.build(:custom_field, :section => section, :program => program)
    end
  end
end

