# frozen_string_literal: true

require "test_helper"

class MobileSystemTestCase < ApplicationSystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [360, 640]
end
