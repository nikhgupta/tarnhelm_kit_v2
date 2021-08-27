# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  prepend_before_action { check_feature_enabled?(:user_passwords) }
  skip_before_action :require_no_authentication, only: [:add_password_to_magic_account]

  def add_password_to_magic_account
    if allow_adding_password?
      current_user.send_reset_password_instructions
      sign_out(resource_name)
      flash[:notice] = I18n.t("devise.passwords.added_and_email_sent")
      redirect_to(new_user_session_path)
    elsif current_user.present?
      flash[:alert] = I18n.t("devise.passwords.already_present")
      redirect_back(fallback_location: root_path)
    else
      flash[:alert] = I18n.t("devise.passwords.unauthenticated")
      redirect_back(fallback_location: root_path)
    end
  end

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  private

  def allow_adding_password?
    current_user&.enabled?(:user_passwords) && !current_user&.password_set?
  end
end
