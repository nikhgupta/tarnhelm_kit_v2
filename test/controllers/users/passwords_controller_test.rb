# frozen_string_literal: true

require "test_helper"

class UsersPasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pass = create(:user, email: "pass@localhost.none")
    @magic = create(:user, email: "magic@localhost.none", password: nil)
  end

  context "no features enabled" do
    should "ensure password feature is disabled" do
      sign_in @pass
      get root_url
      # assert_routes_disabled :add_magic_user_password
      assert_routes_disabled :new_user_password
    end
  end

  context "password feature enabled for a specific user" do
    should "ensure password feature is disabled for logged-in user" do
      Flipper.enable(:user_passwords, @magic)

      sign_in @pass
      get root_url
      assert_routes_disabled :add_magic_user_password

      sign_out @pass
      sign_in @magic

      assert_routes_available :add_magic_user_password
      assert_response :success
    end
  end

  context "password feature enabled for everyone" do
    setup { Flipper.enable(:user_passwords) }
    should "not allow adding password for non-logged-in users" do
      get root_url
      get add_magic_user_password_url

      follow_redirect!
      assert_response :success
      assert_equal flash[:alert], "You need to sign in or sign up before continuing."
      assert_equal request.env["PATH_INFO"], root_path
    end

    should "not allow adding password to users with password set" do
      sign_in @pass

      get root_url
      get add_magic_user_password_url

      follow_redirect!
      assert_response :success
      assert_equal flash[:alert], "You already have a password added to your account."
      assert_equal request.env["PATH_INFO"], root_path
    end

    should "allow adding password to users without a password" do
      sign_in @magic

      get root_url
      get add_magic_user_password_url

      follow_redirect!
      assert_response :success
      assert_equal flash[:notice], "We have sent you an email to add password to your account."
      assert_equal request.env["PATH_INFO"], new_user_session_path
    end
  end
end
