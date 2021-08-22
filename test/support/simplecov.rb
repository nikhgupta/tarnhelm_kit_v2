# frozen_string_literal: true
module ActiveSupport
  class TestCase
    parallelize_setup do |worker|
      SimpleCov.command_name("#{SimpleCov.command_name}-#{worker}")
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
    end
  end
end
