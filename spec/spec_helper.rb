# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'mongoid'
require 'webrat'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec

  # Clean up the database
  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

  Webrat.configure do |config|
    config.mode = :rails
  end

end

def get_user
  return User.create!({
    :name => "tester",
    :password => "testing",
    :email => "test@testing.com"
  })
end

def get_admin_user
  return User.create!({
    :name => "admin",
    :password => "password",
    :email => "admin@testing.com"
  }) do |user|
    user.is_admin = true
  end
end
