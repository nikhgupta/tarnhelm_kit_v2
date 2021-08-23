# frozen_string_literal: true
require "test_helper"

class AuthenticatingIdentityTest < ActiveSupport::TestCase
  attr_reader :auth, :identity

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

  test "find an identity with omniauth data" do
    record = AuthenticatingIdentity.find_with_omniauth(auth)
    assert_equal record, identity

    assert_nil AuthenticatingIdentity.find_with_omniauth(auth.merge(uid: "not-uid"))
  end

  test "encrypts the data in database" do
    record = AuthenticatingIdentity.find_with_omniauth(auth)
    encrypted = ["token", "email", "refresh_token", "auth_data"]
    encrypted.each do |column|
      assert_raises { AuthenticatingIdentity.where(id: record.id).pluck(:salt, column) }
      val = record.send(column)
      cip = record.send("#{column}_ciphertext")
      assert val.present?
      refute_equal val, cip
      assert cip.match?(%r{\A[a-z0-9=\+/]+\z}i)
    end
  end

  test "changing the salt makes data un-decryptable" do
    record = AuthenticatingIdentity.find_with_omniauth(auth)
    record.update(salt: "whatever")

    record = AuthenticatingIdentity.find_with_omniauth(auth)
    assert_raises(Lockbox::DecryptionError) { record.attributes }
  end

  test "#update_salt! can be used to safely update salt" do
    record = AuthenticatingIdentity.find_with_omniauth(auth)
    current_auth_data = record.auth_data
    record.update_salt!("whatever")

    record = AuthenticatingIdentity.find_with_omniauth(auth)
    assert_equal record.auth_data, current_auth_data
  end

  test "check if an identity's token has #expired?" do
    identity.token_expires_at = 15.minutes.since
    assert_equal identity.expired?, false

    identity.token_expires_at = 5.minutes.since
    assert_equal identity.expired?, true
  end

  test "#update_credentials for an identity" do
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

  test "#access_token should be usable for fresh tokens at any time" do
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
