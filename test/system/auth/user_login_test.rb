# frozen_string_literal: true
require "application_system_test_case"

class UserLoginTest < ApplicationSystemTestCase
  class DefaultFeatures < UserLoginTest
    test "visit static pages without logging in" do
      visit root_url
      assert_logged_out_ui

      resize_to_mobile
      assert_logged_out_ui(invert: ["Register"])

      resize_to_desktop
      click_on "About"
      assert_selector "h1", text: "About Page"
    end

    test "logging in with magic link" do
      FactoryBot.create(:user, email: "pass@localhost.none")

      visit root_url

      click_on "Login"
      assert_link "Sign up"
      assert_link "Didn't receive confirmation instructions"
      assert_no_link "Forgot your password?"
      assert_no_field "Password"

      fill_in "Email", with: "wrong-one@localhost.none"
      click_on "Send me a Magic Link"
      assert_flash alert: "Could not find a user for that email address"

      fill_in "Email", with: "pass@localhost.none"
      click_on "Send me a Magic Link"

      open_last_email
      click_first_link_in_email

      assert_logged_in_ui
      assert_flash notice: "Signed in successfully."

      find(".flash.notice [aria-label='Close']").click
      assert_no_flash
    end

    test "logging in with password" do
      FactoryBot.create(:user, email: "pass@localhost.none")

      visit root_url

      click_on "Login"
      assert_no_link "Forgot your password?"
      assert_no_field "Password"

      fill_in "Email", with: "pass@localhost.none"
      click_to_show_password_fields "Want to use your password?"
      assert_no_selector "span[data-devise-toggler]"
      assert_link "Forgot your password?"
      assert_field "Password"

      fill_in "Password", with: "password"
      click_on "Log in"

      assert_logged_in_ui
      assert_flash notice: "Signed in successfully."
    end

    test "logging in for magic-link only users while providing password" do
      FactoryBot.create(:user, email: "magic@localhost.none", password: nil)

      visit new_user_session_url
      fill_in "Email", with: "magic@localhost.none"
      click_to_show_password_fields "Want to use your password?"
      fill_in "Password", with: "password"
      click_on "Log in"

      assert_equal page.current_url, new_user_session_url
      assert_flash notice: /login link has been sent to your email address/

      open_last_email
      click_first_link_in_email

      assert_logged_in_ui
      assert_flash notice: "Signed in successfully."
    end
  end

  class PasswordsDisabled < UserLoginTest
    test "do not display password related links/triggers" do
      disable_feature :user_passwords

      visit root_url
      click_on "Login"
      assert_button "Send me a Magic Link"

      assert_no_link "Forgot your password?"
      assert_no_field "Password"
      assert_no_selector "span[data-devise-toggler]"
      assert_no_selector "span", text: "Want to use your password?"
    end
  end

  class RegistrationDisabled < UserLoginTest
    test "do not show links for sign up" do
      disable_feature :user_registrations

      visit root_url
      click_on "Login"
      assert_button "Send me a Magic Link"

      assert_no_link "Forgot your password?"
      assert_no_link "Sign up"
    end
  end

  class OmniauthDisabled < UserLoginTest
    test "do not display links for omniauth" do
      disable_feature :user_omniauth

      visit new_user_session_url
      assert_button "Send me a Magic Link"
      assert_no_button "Log in with Google"
    end
  end

  class MagicLinksDisabled < UserLoginTest
    test "fallback to password based login" do
      FactoryBot.create(:user, email: "pass@localhost.none")

      disable_feature :user_magic_links

      visit root_url
      click_on "Login"

      assert_link "Sign up"
      assert_link "Didn't receive confirmation instructions"
      assert_link "Forgot your password?"
      assert_field "Password", text: ""
      assert_no_button "Send me a Magic Link"
      assert_button "Log in"

      fill_in "Email", with: "wrong-user@localhost.none"
      fill_in "Password", with: "password"
      click_on "Log in"
      assert_flash alert: "Invalid Email or password"

      fill_in "Email", with: "pass@localhost.none"
      fill_in "Password", with: "wrong-password"
      click_on "Log in"
      assert_flash alert: "Invalid Email or password."

      fill_in "Email", with: "pass@localhost.none"
      fill_in "Password", with: "password"
      click_on "Log in"
      assert_logged_in_ui
      assert_flash notice: "Signed in successfully."

      find(".flash.notice [aria-label='Close']").click
      assert_no_flash
    end
  end
end
