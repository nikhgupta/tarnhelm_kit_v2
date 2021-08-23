# frozen_string_literal: true
class User < ApplicationRecord
  include Encryptable

  devise :database_authenticatable,
    :magic_link_authenticatable,
    :registerable,
    :confirmable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable,
    :omniauthable,
    omniauth_providers: [:google, :twitter]

  validates_confirmation_of :password, if: -> { password.present? }

  has_person_name
  has_one_attached :avatar
  has_many :authenticating_identities, dependent: :destroy

  def self.internal(id)
    find_by(email: "#{id}@#{Tarnhelm.app.host}")
  end

  def authenticating_identity_for(provider)
    authenticating_identities.find_by(provider: provider)
  end

  def generated_email?
    email.include?("@#{Tarnhelm.app.generated_email_domain}")
  end

  def enabled?(feature)
    Flipper.enabled?(feature.to_sym, self)
  end

  def can_login_using_password?
    enabled?(:user_passwords) && encrypted_password.present?
  end

  def requires_magic_link?
    enabled?(:user_magic_links) && !can_login_using_password?
  end

  def after_magic_link_authentication
    confirm if unconfirmed_email.present? && !confirmed?
  end

  def gravatar_url(options = {})
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://www.gravatar.com/avatar/#{hash}?#{options.to_query}"
  end
end
