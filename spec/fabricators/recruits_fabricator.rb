Fabricator(:recruit, from: :person, class_name: 'Recruit') do
  first_name { Fabricate.sequence(:first_name) { |i| "Recruit#{i}" } }
  last_name { Fabricate.sequence(:last_name) { |i| "Smith#{i}" } }
  email {Fabricate.sequence(:email) { |i| "user#{i}@highschool.local" } }
  program!
end

Fabricator(:transfer_recruit, from: :recruit, class_name: 'Recruit') do
  student_type 'Transfer Student'
end

Fabricator(:baseball_recruit, :class_name => Sport::Baseball, :from => :recruit) do
end

Fabricator(:basketball_recruit, :class_name => Sport::Basketball, :from => :recruit) do
end

Fabricator(:bowling_recruit, :class_name => Sport::Bowling, :from => :recruit) do
end

Fabricator(:cheer, :class_name => Sport::Cheer, :from => :recruit) do
end

Fabricator(:cross_country, :class_name => Sport::CrossCountry, :from => :recruit) do
end

Fabricator(:dance, :class_name => Sport::Golf, :from => :recruit) do
end

Fabricator(:equestrian_recruit, :class_name => Sport::Equestrian, :from => :recruit) do
end

Fabricator(:field_hockey, :class_name => Sport::FieldHockey, :from => :recruit) do
end

Fabricator(:football, :class_name => Sport::Football, :from => :recruit) do
end

Fabricator(:golf_event, :class_name => Sport::GolfEvent) do
end

Fabricator(:golf, :class_name => Sport::Golf, :from => :recruit) do
end

Fabricator(:gymnastics, :class_name => Sport::Gymnastics, :from => :recruit) do
end

Fabricator(:gymnastics_event, :class_name => Sport::GymnasticsEvent) do
end

Fabricator(:ice_hockey_recruit, :class_name => Sport::IceHockey, :from => :recruit) do
end

Fabricator(:lacrosse_recruit, :class_name => Sport::Lacrosse, :from => :recruit) do
end

Fabricator(:sales_recruit, :class_name => Sport::Sales, :from => :recruit) do
end

Fabricator(:soccer_recruit, :class_name => Sport::Soccer, :from => :recruit) do
end

Fabricator(:softball, :class_name => Sport::Softball, :from => :recruit) do
end

Fabricator(:swimming_recruit, :class_name => Sport::Swimming, :from => :recruit) do
end

Fabricator(:swimming_event, :class_name => Sport::SwimmingEvent) do
end

Fabricator(:tennis, :class_name => Sport::Tennis, :from => :recruit) do
end

Fabricator(:track_and_field, :class_name => Sport::TrackAndField, :from => :recruit) do
end

Fabricator(:track_and_field_event, :class_name => Sport::TrackAndFieldEvent) do
end

Fabricator(:volleyball, :class_name => Sport::Volleyball, :from => :recruit) do
end

Fabricator(:wrestling, :class_name => Sport::Wrestling, :from => :recruit) do
end
