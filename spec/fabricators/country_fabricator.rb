Fabricator(:country) do
  name { Fabricate.sequence(:name) { |i| "Country #{i}" } }
  #states!(:count => 5) { |country, i| Fabricate(:state, :country => country, :name => "#{country.name}-State #{i}") }
  # No clue why the above stopped working, it's like mongoid forgot how to build associaitons properly.
  # Maybe try using belongs_to and has_many instead of the `references_` methods
  after_create { |country|
    5.times do |i|
      Fabricate(:state, :country => country, :name => "#{country.name}-State #{i}")
    end
  }
end

