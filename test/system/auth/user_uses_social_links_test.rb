# frozen_string_literal: true
require "application_system_test_case"

class UserUsesSocialLinksTest < ApplicationSystemTestCase
  setup { Tarnhelm.activate_initial_features! }

  setup do
    reset_omniauth_mock_for(:google)
    reset_omniauth_mock_for(:twitter)
  end

  context "all features" do
    should "allow user to register/login using Google OAuth2" do
      @login = -> { click_on("Log in with Google") }
      @register = -> { click_on("Sign up with Google") }
      run_omniauth_flow(:google) do |auth|
        assert(auth.email.present?)
        assert(auth.refresh_token.present?)
        assert(auth.token_expires_at.present?)
        assert(auth.first_name.present?)
        assert(auth.last_name.present?)
      end
    end

    should "allow user to register/login using Twitter OAuth2" do
      @login = -> { find(".oauth-twitter").click }
      @register = -> { find(".oauth-twitter").click }
      run_omniauth_flow(:twitter) do |auth|
        assert(auth.email.blank?)
        assert(auth.refresh_token.present?)
        assert(auth.token_expires_at.blank?)
        assert(auth.first_name.blank?)
        assert(auth.last_name.blank?)
      end
    end

    should "allow user to add identity when logged in" do
      sign_in_via_google
      assert_linked_via_google
    end

    should "allow user to remove identity when logged in" do
      current = sign_in_via_google
      visit edit_user_registration_url
      click_on "Social Logins"

      assert_no_button "Link your Google account"
      assert current.authenticating_identity_for(:google).present?

      click_on "Remove"
      assert_button "Link your Google account"
      assert current.authenticating_identity_for(:google).blank?
    end

    should "re-assign identity to latest authenticating user" do
      user = FactoryBot.create(:user, email: "john@localhost.none")
      prev = sign_in_via_google
      sign_out

      sign_in_as(user.email)
      visit edit_user_registration_url

      click_on "Social Logins"
      find(".oauth-google").click
      assert_flash notice: "Successfully linked your Google account with this account."

      assert user.authenticating_identity_for(:google).present?
      assert prev.authenticating_identity_for(:google).blank?
    end

    should "redirect to registration page if sign up info is missing" do
      OmniAuth.config.mock_auth[:google] = OmniAuth.config.mock_auth[:default]
      sign_in_via_google assertion: false
      assert_flash notice: "We need a few more details from you."
      assert_equal page.current_url, new_user_registration_url
    end

    should "auto-assign an email if missing from provider" do
      OmniAuth.config.mock_auth[:google].deep_merge!(info: { email: nil })
      current = sign_in_via_google
      assert_linked_via_google
      within(".oauth-google") { assert_content /UID: \d+/ }
      assert current.email =~ /google-\d+@identity\.users\..+/
    end

    should "show errors in UI on omniauth error" do
      OmniAuth.config.mock_auth[:google] = :some_error
      sign_in_via_google assertion: false
      assert_flash alert: 'Could not authenticate you using your Google account because of "Some error"'
      assert_equal page.current_url, new_user_session_url
    end
  end

  private

  def run_omniauth_flow(provider)
    visit(new_user_registration_url)

    count = User.count
    VCR.use_cassette("omniauth_#{provider}") { @register.call }
    assert_equal(User.count, count + 1)
    assert_flash(notice: "Successfully registered using your #{provider.to_s.titleize} account.")

    user = User.last
    assert(user.confirmed?)
    assert(user.name.present?)
    assert(user.email.present?)
    assert(user.avatar.present?)
    assert_equal(user.authenticating_identities.count, 1)

    auth = user.authenticating_identities.first
    assert_equal(auth.provider, provider.to_s)
    assert(auth.uid.present?)
    assert(auth.token.present?)
    yield(auth)
    assert(auth.auth_data["extra"]["raw_info"].present?)

    user.avatar.destroy
    auth.avatar.destroy

    sign_out
    visit(new_user_session_url)
    VCR.use_cassette("omniauth_#{provider}") { @login.call }
    assert_flash(notice: "Signed in successfully")

    assert(user.reload.avatar.present?)
    assert(auth.reload.avatar.present?)
  end
end
