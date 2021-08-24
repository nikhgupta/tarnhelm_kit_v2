# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  should "get root path" do
    get root_url
    assert_response :success
  end

  should "be 404 page" do
    exceptions = assert_routes_disabled(pages_url(id: "non-existing-static-page"))
    message = 'No route matches [GET] "/pages/non-existing-static-page"'
    assert_equal exceptions.first.message, message
  end
end
