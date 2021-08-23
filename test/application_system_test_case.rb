# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1366, 768]

  include DeviseSystemTestHelpers
  include CapybaraSystemTestHelpers
end
