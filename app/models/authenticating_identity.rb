# frozen_string_literal: true
class AuthenticatingIdentity < ApplicationRecord
  include Encryptable
  encrypts_each_row_of :token, :email, :refresh_token
  encrypts_each_row_of :auth_data, type: :json

  belongs_to :user
  has_one_attached :avatar

  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid, scope: :provider, case_sensitive: false

  def name
    OmniAuth::Utils.camelize(provider)
  end

  def self.find_with_omniauth(auth)
    find_by(uid: auth[:uid], provider: auth[:provider])
  end

  # get fresh access token from the database
  def access_token
    update_credentials(oauth_token.refresh!) if expired?
    token
  end

  def expired?
    token_expires_at? && token_expires_at <= 10.minutes.since
  end

  def update_credentials(creds)
    return if creds.blank?
    data = { token: creds[:token] }
    data[:token_expires_at] = Time.at(creds[:expires_at]) if creds[:expires_at].present?
    data[:refresh_token] = creds[:secret] if creds[:secret].present?
    data[:refresh_token] = creds[:refresh_token] if creds[:refresh_token].present?
    update(data)
  end

  private

  def oauth_token
    klass = provider == "google" ? "GoogleOauth2" : provider.classify
    strategy = OmniAuth::Strategies.const_get(klass).new(nil,
      Rails.application.credentials.oauth[provider.to_sym][:app_id],
      Rails.application.credentials.oauth[provider.to_sym][:app_secret])

    OAuth2::AccessToken.new(strategy.client, token, refresh_token: refresh_token)
  end
end
