require 'simplecov'
SimpleCov.start 'rails' if ENV["COVERAGE"]

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'acceptance/acceptance_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/acceptance/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  config.include Devise::TestHelpers, :type => :controller

  config.before(:each) do
    Time.zone = nil #leaky global :(
    DatabaseCleaner.orm = :mongoid
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.before(:each, :type => :request) do
    Capybara.reset_sessions!
    Capybara.default_selector = :css
    Capybara.current_driver = :selenium if example.metadata[:js]
  end

  config.after(:each, :type => :request) do
    Capybara.use_default_driver
  end
end

Delayed::Worker.delay_jobs = !Rails.env.test?
