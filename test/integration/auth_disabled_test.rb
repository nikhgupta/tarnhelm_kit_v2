# frozen_string_literal: true

require "test_helper"

class AuthDisabledTest < ActionDispatch::IntegrationTest
  context "via default features" do
    should "have all auth routes available" do
      assert_routes_available :new_user_session, :users_magic_link
      assert_routes_available :user_session, method: :post
      assert_routes_available :destroy_user_session, method: :delete

      assert_routes_available :users_magic_link

      assert_routes_available :new_user_password, :edit_user_password, :add_magic_user_password
      assert_routes_available :user_password, method: [:put, :patch, :post]

      assert_routes_available :cancel_user_registration, :new_user_registration, :edit_user_registration
      assert_routes_available :user_registration, method: [:put, :patch, :post, :delete]

      assert_routes_available :new_user_confirmation, :user_confirmation
      assert_routes_available :user_confirmation, method: :post

      ["google", "twitter"].each do |provider|
        VCR.use_cassette("omniauth_#{provider}") do
          assert_routes_available "user_#{provider}_omniauth_callback".to_sym
          assert_routes_available "user_#{provider}_omniauth_authorize".to_sym
          assert_routes_available "user_#{provider}_omniauth_callback".to_sym, method: :post
          assert_routes_available "user_#{provider}_omniauth_authorize".to_sym, method: :post
        end
      end
    end
  end

  context "via feature toggles" do
    should "allow disabling magic link routes" do
      disable_feature :user_magic_links
      assert_routes_disabled :users_magic_link
    end

    should "allow disabling password routes" do
      disable_feature :user_passwords
      assert_routes_disabled :new_user_password, :add_magic_user_password, :edit_user_password
      assert_routes_disabled :user_password, method: [:put, :patch, :post]
    end

    should "allow disabling registration routes" do
      disable_feature :user_registrations
      assert_routes_disabled :cancel_user_registration, :new_user_registration
      assert_routes_disabled :user_registration, method: [:post, :delete]
    end

    should "allow disabling omniauth routes" do
      disable_feature :user_omniauth
      assert_routes_disabled :user_google_omniauth_callback, :user_twitter_omniauth_callback
      assert_routes_disabled :user_google_omniauth_authorize, :user_twitter_omniauth_authorize
      assert_routes_disabled :user_google_omniauth_callback, :user_twitter_omniauth_callback, method: :post
      assert_routes_disabled :user_google_omniauth_authorize, :user_twitter_omniauth_authorize, method: :post
    end
  end
end
