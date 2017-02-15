namespace :data do
  desc "Standardize states in database"
  task :standardize_states => :environment do
    Mongoid.database['people'].find().each do |person|
      if person["address"] && person["address"]["state"] && person["address"]["state"].length == 2
        person["address"]["state"] = ModelUN.convert(person["address"]["state"])
        Mongoid.database['people'].save(person)
      end
    end
  end
end
