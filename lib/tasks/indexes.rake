#This is a fix because the mongoid version doesn't pull in the autoload paths so it crashes trying to deal with files like models/people/coach

namespace :scoutforce do
  desc 'Create the indexes defined on your mongoid models'
  task :create_indexes => :environment do
    engines_models_paths = Rails.application.railties.engines.map do |engine|
      engine.paths["app/models"].expanded
    end
    root_models_paths = Rails.application.paths["app/models"]
    models_paths = engines_models_paths.push(root_models_paths).flatten

    models_paths.each do |path|
      ::Rails::Mongoid.create_indexes("#{path}/*.rb")
    end
  end
end
