# frozen_string_literal: true
require "test_helper"
require_relative "concerns/encryptable_test"

class AuthenticatingIdentityTest < ActiveSupport::TestCase
  attr_reader :auth, :identity

  include EncryptableTest
  should_encrypt_attributes :token, :refresh_token, :email, :auth_data

  subject { build(:authenticating_identity) }

  should belong_to(:user)
  should have_one_attached(:avatar)
  should validate_presence_of(:provider)
  should validate_presence_of(:uid)
  should validate_uniqueness_of(:uid).scoped_to(:provider).case_insensitive

  setup do
    reset_omniauth_mock_for(:google)
    @identity ||= VCR.use_cassette("omniauth_google") do
      @auth = OmniAuth.config.mock_auth[:google]
      service = OmniauthAuthenticatorService.new(auth)
      service.run
      service.identity
    end

    @identity.reload
  end

  should "find an identity with omniauth data" do
    record = AuthenticatingIdentity.find_with_omniauth(auth)
    assert_equal record, identity

    assert_nil AuthenticatingIdentity.find_with_omniauth(auth.merge(uid: "not-uid"))
  end

  should "check if an identity's token has #expired?" do
    identity.token_expires_at = 15.minutes.since
    assert_equal identity.expired?, false

    identity.token_expires_at = 5.minutes.since
    assert_equal identity.expired?, true
  end

  should "#update_credentials for an identity" do
    data = { token: identity.token, refresh_token: identity.refresh_token,
             token_expires_at: identity.token_expires_at, }

    identity.update_credentials(token: "xyz")
    assert_equal identity.token, "xyz"
    assert_equal identity.refresh_token, data[:refresh_token]
    assert_equal identity.token_expires_at, data[:token_expires_at]

    identity.update_credentials(token: "xyz", refresh_token: "abc")
    assert_equal identity.token, "xyz"
    assert_equal identity.refresh_token, "abc"
    assert_equal identity.token_expires_at, data[:token_expires_at]

    identity.update_credentials(token: "xyz", refresh_token: "abc",
      expires_at: 1.hour.to_i + data[:token_expires_at].to_i)
    assert_equal identity.token, "xyz"
    assert_equal identity.refresh_token, "abc"
    assert identity.token_expires_at > data[:token_expires_at]
  end

  should "allow #access_token for fresh tokens at any time" do
    assert_equal identity.expired?, false
    assert_equal identity.token, identity.access_token

    identity.token_expires_at = 5.minutes.ago
    assert_equal identity.expired?, true

    token = stub(refresh!: { token: "xyz", refresh_token: "abc", expires_at: 1.hour.since })
    OAuth2::AccessToken.expects(:new).returns(token)
    assert_equal identity.access_token, "xyz"
    assert_equal identity.refresh_token, "abc"
    assert identity.token_expires_at > Time.current
  end
end
