# frozen_string_literal: true
require "application_system_test_case"

class UserRegistersTest < ApplicationSystemTestCase
  context "default features" do
    should "allow user to register using email only" do
      visit root_url
      click_on "Register"
      assert_button "Send me a Magic Link"
      assert_no_field "Password"

      fill_in "Email", with: "new-magic-user@localhost.none"
      click_on "Send me a Magic Link"

      assert_flash notice: /message with a confirmation link has been sent/
      assert_no_flash alert: "Could not find a user for that email address"

      open_last_email
      click_first_link_in_email

      assert_logged_in_ui
      assert_flash notice: "email address has been successfully confirmed"
    end

    should "allow user to register with a password" do
      visit root_url
      click_on "Register"
      assert_button "Send me a Magic Link"
      assert_no_field "Password"
      assert_no_field "Password confirmation"

      click_to_show_password_fields
      assert_no_selector "span[data-devise-toggler]"
      assert_field "Password confirmation"

      fill_in "Email", with: "new-magic-user@localhost.none"
      fill_in "Password", with: "password", match: :prefer_exact
      fill_in "Password confirmation", with: "wrong-password"
      click_on "Register"
      assert_flash alert: "Password confirmation doesn't match Password"
      assert_no_field "Password confirmation"

      click_to_show_password_fields
      assert_field "Password confirmation"

      fill_in "Email", with: "new-magic-user@localhost.none"
      fill_in "Password", with: "password", match: :prefer_exact
      fill_in "Password confirmation", with: "password"
      click_on "Register"
      assert_flash notice: /message with a confirmation link has been sent/

      open_last_email
      click_first_link_in_email

      assert_logged_in_ui
      assert_flash notice: "email address has been successfully confirmed"
    end
  end

  context "passwords disabled" do
    should "not allow user to register with a password" do
      disable_feature :user_passwords

      visit root_url
      click_on "Register"
      assert_button "Send me a Magic Link"

      assert_no_field "Password"
      assert_no_field "Password confirmation"
      assert_no_selector "span[data-devise--password-area-toggler]"
      assert_no_selector "span", text: "Add a password? (not recommended)"
    end
  end

  context "omniauth disabled" do
    should "not display links for omniauth" do
      disable_feature :user_omniauth

      visit new_user_registration_url
      assert_button "Send me a Magic Link"
      assert_no_button "Sign up with Google"
    end
  end

  context "magic links disabled" do
    should "fallback to password based registration" do
      disable_feature :user_magic_links

      visit root_url
      click_on "Register"

      assert_link "Log in"
      assert_link "Didn't receive confirmation instructions"
      assert_field "Password", text: ""
      assert_field "Password confirmation", text: ""
      assert_no_button "Send me a Magic Link"

      fill_in "Email", with: "new-magic-user@localhost.none"
      fill_in "Password", with: "password", match: :prefer_exact
      fill_in "Password confirmation", with: "password"
      click_on "Register"
      assert_flash notice: /message with a confirmation link has been sent/

      open_last_email
      click_first_link_in_email

      assert_logged_in_ui
      assert_flash notice: "email address has been successfully confirmed"
    end
  end
end
