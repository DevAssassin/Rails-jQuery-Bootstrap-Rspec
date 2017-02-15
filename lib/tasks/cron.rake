desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  # Examples from Heroku (see http://devcenter.heroku.com/articles/cron):
  #if Time.now.hour % 4 == 0 # run every four hours
  #  puts "Updating feed..."
  #  NewsFeed.update
  #  puts "done."
  #end

  #if Time.now.hour == 0 # run at midnight
  #  User.send_reminders
  #end

  # Change the number below to X to run cron every X hours
  if Time.now.hour % 1 == 0
    Email.send_scheduled_emails
  end
end
