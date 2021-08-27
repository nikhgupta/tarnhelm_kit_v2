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

  has_many :memberships, dependent: :destroy
  has_many :accounts, through: :memberships
  has_many :invitees, -> { distinct }, through: :memberships

  has_many :invitations, class_name: "Membership", foreign_key: :invited_by_id
  has_many :invited_users, through: :invitations, source: :user, class_name: to_s

  after_create :create_personal_account

  def self.internal(id)
    find_by(email: "#{id}@#{Tarnhelm.app.host}")
  end

  def personal_account
    accounts.personal.first
  end

  def account_with(id)
    accounts.find_by(id: id)
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

  def password_set?
    encrypted_password.present?
  end

  def can_login_using_password?
    enabled?(:user_passwords) && password_set?
  end

  def requires_magic_link?
    enabled?(:user_magic_links) && !can_login_using_password?
  end

  def after_magic_link_authentication
    confirm if unconfirmed_email.present? && !confirmed?
  end

  private

  def create_personal_account
    return if personal_account.present?
    accounts.create(personal: true, name: "Personal Account (#{email})")
  end
end
