# frozen_string_literal: true

require "test_helper"

class AuthDisabledTest < ActionDispatch::IntegrationTest
  context "with no features" do
    should "have all auth feature routes disabled" do
      assert_routes_available :new_user_session
      assert_routes_available :user_session, method: :post
      assert_routes_available :destroy_user_session, method: :delete
      assert_routes_available :user_delete_data

      assert_routes_disabled  :users_magic_link

      assert_routes_disabled :new_user_password, :edit_user_password, :add_magic_user_password
      assert_routes_disabled :user_password, method: [:put, :patch, :post]

      assert_routes_disabled :cancel_user_registration, :new_user_registration, :edit_user_registration
      assert_routes_disabled :user_registration, method: [:put, :patch, :post, :delete]

      assert_routes_disabled :new_user_confirmation, :user_confirmation
      assert_routes_disabled :user_confirmation, method: :post

      ["google", "twitter"].each do |provider|
        VCR.use_cassette("omniauth_#{provider}") do
          assert_routes_disabled "user_#{provider}_omniauth_callback".to_sym
          assert_routes_disabled "user_#{provider}_omniauth_authorize".to_sym
          assert_routes_disabled "user_#{provider}_omniauth_callback".to_sym, method: :post
          assert_routes_disabled "user_#{provider}_omniauth_authorize".to_sym, method: :post
        end
      end
    end
  end

  context "via feature toggles" do
    should "with user magic links" do
      Flipper.enable(:user_magic_links)
      assert_routes_available :users_magic_link
      assert_routes_available :edit_user_registration
      assert_routes_available :user_registration, method: [:put, :patch]

      assert_routes_available :new_user_session
      assert_routes_available :user_session, method: :post
      assert_routes_available :destroy_user_session, method: :delete
      assert_routes_available :user_delete_data

      assert_routes_disabled :new_user_password, :edit_user_password, :add_magic_user_password
      assert_routes_disabled :user_password, method: [:put, :patch, :post]

      assert_routes_disabled :cancel_user_registration, :new_user_registration
      assert_routes_disabled :user_registration, method: [:post, :delete]

      assert_routes_disabled :new_user_confirmation, :user_confirmation
      assert_routes_disabled :user_confirmation, method: :post

      ["google", "twitter"].each do |provider|
        VCR.use_cassette("omniauth_#{provider}") do
          assert_routes_disabled "user_#{provider}_omniauth_callback".to_sym
          assert_routes_disabled "user_#{provider}_omniauth_authorize".to_sym
          assert_routes_disabled "user_#{provider}_omniauth_callback".to_sym, method: :post
          assert_routes_disabled "user_#{provider}_omniauth_authorize".to_sym, method: :post
        end
      end
    end

    should "with password feature" do
      Flipper.enable(:user_passwords)
      assert_routes_available :new_user_password, :add_magic_user_password, :edit_user_password
      assert_routes_available :user_password, method: [:put, :patch, :post]
      assert_routes_available :edit_user_registration
      assert_routes_available :user_registration, method: [:put]

      assert_routes_available :new_user_session
      assert_routes_available :user_session, method: :post
      assert_routes_available :destroy_user_session, method: :delete
      assert_routes_available :user_delete_data

      assert_routes_disabled :cancel_user_registration, :new_user_registration
      assert_routes_disabled :user_registration, method: [:post, :delete]

      assert_routes_disabled :new_user_confirmation, :user_confirmation
      assert_routes_disabled :user_confirmation, method: :post

      ["google", "twitter"].each do |provider|
        VCR.use_cassette("omniauth_#{provider}") do
          assert_routes_disabled "user_#{provider}_omniauth_callback".to_sym
          assert_routes_disabled "user_#{provider}_omniauth_authorize".to_sym
          assert_routes_disabled "user_#{provider}_omniauth_callback".to_sym, method: :post
          assert_routes_disabled "user_#{provider}_omniauth_authorize".to_sym, method: :post
        end
      end
    end

    should "with registration routes" do
      Flipper.enable(:user_registrations)
      assert_routes_available :cancel_user_registration, :new_user_registration
      assert_routes_available :user_registration, method: [:post, :delete]

      assert_routes_available :new_user_session
      assert_routes_available :user_session, method: :post
      assert_routes_available :destroy_user_session, method: :delete
      assert_routes_available :user_delete_data

      assert_routes_disabled :new_user_password, :edit_user_password, :add_magic_user_password
      assert_routes_disabled :user_password, method: [:put, :patch, :post]

      assert_routes_disabled :edit_user_registration
      assert_routes_disabled :user_registration, method: [:put]

      assert_routes_available :new_user_confirmation, :user_confirmation
      assert_routes_available :user_confirmation, method: :post

      ["google", "twitter"].each do |provider|
        VCR.use_cassette("omniauth_#{provider}") do
          assert_routes_disabled "user_#{provider}_omniauth_callback".to_sym
          assert_routes_disabled "user_#{provider}_omniauth_authorize".to_sym
          assert_routes_disabled "user_#{provider}_omniauth_callback".to_sym, method: :post
          assert_routes_disabled "user_#{provider}_omniauth_authorize".to_sym, method: :post
        end
      end
    end

    should "with omniauth routes" do
      Flipper.enable(:user_omniauth)
      Flipper.enable(:user_registrations)

      ["google", "twitter"].each do |provider|
        VCR.use_cassette("omniauth_#{provider}") do
          assert_routes_available "user_#{provider}_omniauth_callback".to_sym
          assert_routes_available "user_#{provider}_omniauth_authorize".to_sym
          assert_routes_available "user_#{provider}_omniauth_callback".to_sym, method: :post
          assert_routes_available "user_#{provider}_omniauth_authorize".to_sym, method: :post
        end
      end

      assert_routes_available :edit_user_registration
      assert_routes_available :user_registration, method: [:put]

      assert_routes_available :new_user_session
      assert_routes_available :user_session, method: :post
      assert_routes_available :destroy_user_session, method: :delete
      assert_routes_available :user_delete_data

      assert_routes_disabled :new_user_password, :edit_user_password, :add_magic_user_password
      assert_routes_disabled :user_password, method: [:put, :patch, :post]

      assert_routes_available :cancel_user_registration, :new_user_registration
      assert_routes_available :user_registration, method: [:post, :delete]

      assert_routes_available :new_user_confirmation, :user_confirmation
      assert_routes_available :user_confirmation, method: :post
    end
  end
end
