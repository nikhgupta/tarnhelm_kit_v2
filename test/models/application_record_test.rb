# frozen_string_literal: true
require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  should "add missing information when available" do
    user = create(:user)
    assert_nil user.first_name

    user.add_info_if_missing(:first_name, "Test")
    assert_equal user.first_name, "Test"
    assert_nil user.reload.first_name

    user.add_info_if_missing(:first_name, "")
    assert_nil user.first_name
    assert_nil user.reload.first_name

    user.add_info_if_missing(:first_name, nil)
    assert_nil user.first_name
    assert_nil user.reload.first_name

    user.first_name = "Another"
    user.add_info_if_missing(:first_name, "Test")
    assert_equal user.first_name, "Another"
  end
end
