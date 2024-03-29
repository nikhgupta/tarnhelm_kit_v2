# frozen_string_literal: true

require "simplecov"
ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include FactoryBot::Syntax::Methods
    include Devise::Test::IntegrationHelpers
  end
end

Dir.glob(Rails.root.join("test", "support", "**", "*.rb")).each { |file| require file }
