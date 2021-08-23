# frozen_string_literal: true
require "minitest-matchers"
require "email_spec"

module ActiveSupport
  class TestCase
    include EmailSpec::Helpers
    include EmailSpec::Matchers
  end
end
