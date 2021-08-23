# frozen_string_literal: true
module CapybaraSystemTestHelpers
  def visit_and_wait(url)
    visit(url)

    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep(0.1) until current_url.include?(url)
    end
  end

  def resize_to_mobile
    page.driver.browser.manage.window.resize_to(360, 640)
  end

  def resize_to_desktop
    page.driver.browser.manage.window.resize_to(1366, 768)
  end

  def assert_flash(map = {})
    map.each do |key, message|
      if message
        assert_selector(".flash.#{key}", text: message)
      else
        assert_no_selector(".flash.#{key}")
      end
    end
  end

  def assert_no_flash(map = nil)
    map ||= { alert: nil, notice: nil }
    map.each do |key, message|
      if message
        assert_no_selector(".flash.#{key}", text: message)
      else
        assert_no_selector(".flash.#{key}")
      end
    end
  end
end
