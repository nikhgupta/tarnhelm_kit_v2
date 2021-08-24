# frozen_string_literal: true
require "application_system_test_case"

class UserUpdatesProfileTest < ApplicationSystemTestCase
  setup do
    create(:user,
      email: "john@localhost.none",
      unconfirmed_email: "unconfirmed-john@localhost.none",
      confirmation_sent_at: 1.day.ago,
      confirmation_token: SecureRandom.urlsafe_base64)

    create(:user, password: nil, email: "magic@localhost.none")
  end

  context "default features" do
    should "allow user with password auth to update email" do
      sign_in_as("john@localhost.none")

      visit edit_user_registration_url
      assert page.has_field?("user_email", with: "john@localhost.none")
      assert_flash notice: "Currently waiting confirmation for: unconfirmed-john@localhost.none"
      assert_link "Delete my Data"

      # assert that this notification is persistent
      assert_no_selector ".flash.notice [aria-label='Close']"
      find(".flash.notice").click
      assert_flash notice: "Currently waiting confirmation for: unconfirmed-john@localhost.none"

      click_on "Edit Profile"
      assert_button "Update Profile"

      fill_in "user_email", with: "new-john@localhost.none"
      assert_field "user_email", with: "new-john@localhost.none"
      fill_in "user_name", with: "John George"
      assert_field "user_name", with: "John George"

      click_on "Update Profile"
      assert_flash notice: /updated your account successfully.*verify your new email address/

      open_last_email
      click_first_link_in_email
      assert_flash notice: /email address has been successfully confirmed/

      visit edit_user_registration_url
      assert_no_flash
      click_on "Edit Profile"
      assert_field "user_email", with: "new-john@localhost.none"
      assert_field "user_name", with: "John George"

      user = User.find_by(email: "new-john@localhost.none")
      assert user.present?
      assert_equal user.name, "John George"

      assert_nil User.find_by(email: "john@localhost.none")
    end

    should "allow user with password auth to update password" do
      sign_in_as("john@localhost.none")

      visit edit_user_registration_url
      assert_field "user_email", with: "john@localhost.none"
      assert_flash notice: "Currently waiting confirmation for: unconfirmed-john@localhost.none"
      assert_link "Delete my Data"

      click_on "Change Password"
      fill_in "user_password", with: "password-2"
      fill_in "user_password_confirmation", with: "password-2"
      fill_in "user_current_password", with: "password"
      click_on "Update Password"
      assert_flash notice: "Your account has been updated successfully."

      sign_out
      sign_in_as("john@localhost.none", "password-2")
    end

    should "allow user with magic auth to add password to their profile" do
      sign_in_as("magic@localhost.none")

      visit edit_user_registration_url
      assert_field "user_email", with: "magic@localhost.none"
      assert_link "Delete my Data"

      click_on "Change Password"
      assert_no_field "user_password"
      assert_no_field "user_password_confirmation"

      click_on "Add password to my account"
      assert_flash notice: /sent.*email to add password to your account/
      assert_equal page.current_url, new_user_session_url

      open_last_email
      click_first_link_in_email
      assert_current_url_contains edit_user_password_url

      fill_in "New password", with: "magic-password"
      fill_in "Confirm new password", with: "wrong-password"
      click_on "Add password to my account"
      assert_flash alert: "Password confirmation doesn't match Password"

      # FIXME: this should still say "Add password to my account"
      click_on "Change my password"
      assert_flash alert: "Password can't be blank"

      fill_in "New password", with: "magic-password"
      fill_in "Confirm new password", with: "magic-password"
      click_on "Add password to my account"
      assert_flash notice: /password has been changed.*now signed in/

      visit edit_user_registration_url
      click_on "Change Password"
      assert_field "user_password"
      assert_field "user_password_confirmation"
    end

    should "allow user with magic auth to change email on their profile" do
      sign_in_as("magic@localhost.none")

      visit edit_user_registration_url
      assert_field "user_email", with: "magic@localhost.none"

      fill_in "user_email", with: "new-magic@localhost.none"
      click_on "Update Profile"
      assert_flash notice: /updated your account successfully.*verify your new email address/

      open_last_email
      click_first_link_in_email
      assert_flash notice: /email address has been successfully confirmed/

      visit edit_user_registration_url
      assert_no_flash
      assert_field "user_email", with: "new-magic@localhost.none"

      sign_out
      sign_in_as("new-magic@localhost.none")
    end
  end

  context "with passwords disabled" do
    should "not show password fields to user or allow him to add passwords" do
      disable_feature :user_passwords

      sign_in_as("magic@localhost.none")
      visit edit_user_registration_url
      assert_field "user_email", with: "magic@localhost.none"

      assert_link "Delete my Data"
      assert_field "user_email"
      assert_no_flash

      assert_no_link "Change Password"
      assert_no_field "user_password"
      assert_no_field "user_password_confirmation"
      assert_no_link "Add password to my account"
    end
  end
end
