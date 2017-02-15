source 'http://rubygems.org'

gem 'rails', '3.2.19'
gem 'rails_autolink'

gem 'jquery-rails', '2.1.4'
gem 'haml-rails'

gem 'hirb'

gem 'nokogiri'

gem 'email_validator'


group :assets do
  gem "coffee-rails"
  gem 'sass-rails'
  gem 'sass', '~> 3.2'
  gem "uglifier"
  gem 'compass-rails'
  gem 'therubyracer', platforms: :ruby
end

#gem "mongoid", :ref => '9d2d0ac5f96', :git => 'git://github.com/mongoid/mongoid.git'
gem 'mongoid', '~> 2.8'
gem "bson_ext"
gem "devise", "~> 2.0.6"
gem 'canable'
gem "responders"
#git "git://github.com/bdimcheff/formtastic.git", :ref => '7849717' do
gem 'formtastic', '2.1.1'

gem 'mongoid_taggable_with_context'
# gem "cells", :git => 'git://github.com/JangoSteve/cells.git', :branch => 'rails-dependency'
gem "cells", "~> 3.7.1"
gem "fabrication"
gem "twilio"
gem "chronic_duration"
gem "basic_active_model"
gem "loofah"
gem "rmagick", :git => 'git://github.com/znz/rmagick.git', :branch => 'pkg_config'
gem "carrierwave"
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem "mustache"
gem "decoder"
gem "us_states_select"
git "git://github.com/bdimcheff/iso_countries.git" do
  gem "iso_countries"
end
gem "mongoid_touch", :git => "git://github.com/JangoSteve/mongoid_touch.git", :branch => 'activesupport-dependency'
gem "kronic"
gem "chronic"
gem "prawn"
gem "mongoid_phone_number", :git => "git://github.com/JangoSteve/mongoid_phone_number.git", :branch => 'activesupport-dependency'
gem "tabs_on_rails"
gem 'prawnto_2', :require => 'prawnto'
gem 'tinymce-rails', '3.5.8.3'
gem 'daemons'
gem 'delayed_job_mongoid'
gem 'model_un'
gem 'ruby2ruby', '1.3.0' #1.3.1 causes trouble in Reek
gem 'dalli'

gem 'airbrake'

gem 'newrelic_rpm'


# For mobile app
gem "sinatra"
gem 'charlock_holmes'
group :staging, :production do
  gem 'foreman', '0.26.1'
  gem 'fog'
end

group :test do
  gem "rspec-cells", :git => 'git://github.com/JangoSteve/rspec-cells.git', :branch => 'rails-dependency'
  gem "rspec-rails", "~> 2.7.0"
  gem "capybara"
  gem "launchy"
  gem "watchr"
  gem 'rack-test', '~> 0.6.1'
  gem 'shoulda-matchers'
  gem 'fuubar'
  gem 'simplecov'
end

group :test, :development do
  gem 'database_cleaner'
  gem 'timecop'
end

group :development do
  gem 'letter_opener'
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'thin'

  gem 'hpricot', '0.8.6'
  gem 'ruby_parser', '2.0.5'
end
