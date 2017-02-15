namespace :users do
  desc "Make user email addresses lower case"
  task :downcase_emails => :environment do
    User.all.each do |u|
      unless u.email == u.email.downcase
        u.email = u.email.downcase
        u.save!(validate: false)
      end
    end
  end
end
