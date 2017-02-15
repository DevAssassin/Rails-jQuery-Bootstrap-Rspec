require 'csv'

namespace :data do
  desc "Import schools into the database"
  task :public_schools => :environment do
    School.create_indexes

    Dir.glob(File.join(Rails.root, "data", "schools", "*.csv")) do |filename|
      CSV.foreach(filename, :headers => true) do |row|
        if row["gshi08"].to_i >= 8 || row["level08"].to_i == 3
          school = School.find_or_initialize_by(:nces_id => row["ncessch"])

          school.name = row["schnam08"]

          school.build_address unless school.address

          school.address.street = row["mstree08"]
          school.address.city = row["mcity08"]
          school.address.state = row["mstate08"]
          school.address.post_code = row["mzip08"]
          school.phone_number = row["phone08"]
          school.subtype = "Public"

          school.save!

          puts "Imported school id #{school.nces_id}: #{school.name}"
        end
      end
    end
  end

  desc "Import private schools into the database"
  task :private_schools => :environment do
    School.create_indexes

    Dir.glob(File.join(Rails.root, "data", "private_schools", "*.csv")) do |filename|
      CSV.foreach(filename, :headers => true) do |row|
        if row["PSS_LEVEL"].to_i == 2 || row["PSS_LEVEL"].to_i == 3
          nces_id = row['PSS_SCHOOL_ID']
          nces_id = sprintf("%08d", nces_id) unless nces_id.length == 8

          school = School.find_or_initialize_by(:nces_id => nces_id)

          school.name = row['PSS_INST']

          school.build_address unless school.address

          school.address.street = row['PSS_ADDRESS']
          school.address.city = row['PSS_CITY']
          school.address.state = row['PSS_STABB']
          school.address.post_code = row['PSS_ZIP5']
          school.phone_number = row['PSS_PHONE']
          school.subtype = "Private"

          school.save!

          puts "Imported school id #{school.nces_id}: #{school.name}"
        end
      end
    end
  end

  desc "Import colleges into the database"
  task :colleges => :environment do
    College.create_indexes

    Dir.glob(File.join(Rails.root, "data", "colleges", "*.csv")) do |filename|
      CSV.foreach(filename, :headers => true) do |row|
        college = College.find_or_initialize_by(:unitid => row['unitid'])

        college.name = row["institution_name"]

        college.build_address unless college.address

        college.address.street    = row['address']
        college.address.city      = row['city']
        college.address.state     = row['state']
        college.address.post_code = row['zip']
        college.phone_number      = row['phone']
        college.subtype           = row['type']

        college.save!

        puts "Imported college id #{college.unitid}: #{college.name}"
      end
    end
  end

  desc "Import country and state codes"
  task :states => :environment do
    CSV.foreach("#{Rails.root}/db/COUNTRIES_STATES.csv") do |row|
      country = Country.find_or_create_by({:name => row[0]})
      if country.states.any_in(:name => [row[1]]).empty?
        country.states << State.new({:name => row[1]})
        country.save
      end
    end
  end
end
