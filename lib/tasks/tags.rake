namespace :tags do
  desc "Migrate tags to program_tags"
  task :rename => :environment do
    Person.collection.update({}, {'$rename' => {'tags' => 'program_tags_array'}}, :multi => true);
    Rake::Task['tags:aggregate'].invoke
  end

  desc "Remove any blank strings in program_tags_array"
  task :clean => :environment do
    Person.collection.update({}, {'$pull' => {'program_tags_array' => ''}}, :multi => true)
    Rake::Task['tags:aggregate'].invoke
  end

  desc "Refresh aggregated tag arrays"
  task :aggregate => :environment do
    Person.aggregate_tags!
  end
end
