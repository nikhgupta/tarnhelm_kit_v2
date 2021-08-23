# frozen_string_literal: true
class OmniauthAuthenticatorService
  attr_reader :auth, :user, :identity, :event

  def initialize(auth, user = nil)
    @auth = auth
    @user = user
    @event = nil
  end

  def kind
    OmniAuth::Utils.camelize(auth[:provider].to_s)
  end

  def email
    return auth[:info][:email] if auth[:info][:email].present?

    "#{auth[:provider]}-#{auth[:uid]}@#{Tarnhelm.app.generated_email_domain}"
  end

  def run
    @identity = find_identity
    if @identity.present?
      if user && @identity.user == user
        @event = :already_authenticated
      elsif user
        @identity.user = user
        @identity.save if @identity.changed?
        @event = :linked
      else
        @event = :signed_in
      end
    else
      @identity = create_identity
      @event = :success if @identity.persisted?
    end
  end

  protected

  def find_identity
    record = AuthenticatingIdentity.find_with_omniauth(auth)
    update_user(record&.user)
    update_identity(record)
  end

  def create_identity
    record = AuthenticatingIdentity.find_or_initialize_by(
      uid: auth[:uid],
      provider: auth[:provider]
    )

    record.user = user || find_or_create_user
    update_identity(record)
  end

  def find_or_create_user
    record = User.find_by(email: email)
    return record if record.present?

    record = User.find_or_initialize_by(email: email)
    update_user(record)
  end

  private

  def update_user(record)
    return record if record.blank?
    record = add_missing_omniauth_info(record)
    record.skip_confirmation!
    record.save

    record
  end

  def update_identity(record)
    return record if record.blank?
    record.add_info_if_missing(:auth_data, auth.to_h)
    record = add_missing_omniauth_info(record)
    record.update_credentials(auth[:credentials])

    record
  end

  def add_missing_omniauth_info(record)
    record.add_info_if_missing(:first_name, auth[:info][:first_name])
    record.add_info_if_missing(:last_name, auth[:info][:last_name])
    record.add_info_if_missing(:name, auth[:info][:name])

    record.add_info_if_missing(:email, auth[:info][:email])

    if auth.dig(:extra, :raw_info).present?
      record.add_info_if_missing(:locale, auth[:extra][:raw_info][:locale])
    end

    if auth[:info][:image].present? && record.avatar.blank?
      io = StringIO.new(Net::HTTP.get(URI(auth[:info][:image])))
      record.avatar.attach(io: io, filename: "user_avatar_via_identity")
    end

    record
  end
end
