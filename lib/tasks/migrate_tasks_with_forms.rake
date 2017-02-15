namespace :tasks do
  desc "MyModel migration task"
  task :migrate_with_forms => :environment do
    require "./db/migrate_tasks_with_forms.rb"
  end
end

