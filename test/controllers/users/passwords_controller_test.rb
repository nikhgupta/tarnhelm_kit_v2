# frozen_string_literal: true

require "test_helper"

class UsersPasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pass = FactoryBot.create(:user, email: "pass@localhost.none")
    @magic = FactoryBot.create(:user, email: "magic@localhost.none", password: nil)
  end

  class DefaultFeatures < UsersPasswordsControllerTest
    test "should not allow adding password for non-logged-in users" do
      get root_url
      get add_magic_user_password_url

      follow_redirect!
      assert_response :success
      assert_equal flash[:alert], "You need to sign in or sign up before continuing."
      assert_equal request.env["PATH_INFO"], root_path
    end

    test "should not allow adding password to account with password set" do
      sign_in @pass

      get root_url
      get add_magic_user_password_url

      follow_redirect!
      assert_response :success
      assert_equal flash[:alert], "You already have a password added to your account."
      assert_equal request.env["PATH_INFO"], root_path
    end
  end

  class PasswordsDisabled < UsersPasswordsControllerTest
    test "password feature is disabled" do
      disable_feature :user_passwords

      sign_in @pass
      get root_url
      assert_routes_disabled :add_magic_user_password
      assert_routes_disabled :new_user_password
    end

    test "password feature is disabled for logged-in user" do
      disable_feature :user_passwords
      Flipper.enable(:user_passwords, @magic)

      sign_in @pass
      get root_url
      assert_routes_disabled :add_magic_user_password

      sign_out @pass
      sign_in @magic

      assert_routes_available :add_magic_user_password
      follow_redirect!
      assert_response :success
    end
  end
end
