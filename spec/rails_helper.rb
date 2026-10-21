# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
ENV['JWT_SECRET'] = 'test-jwt-secret' if ENV['JWT_SECRET'].to_s.empty?
test_database_url = ENV.fetch('TEST_DATABASE_URL', '')
ENV['DATABASE_URL'] = test_database_url unless test_database_url.empty?

require File.expand_path('../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'factory_bot_rails'
require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
end
