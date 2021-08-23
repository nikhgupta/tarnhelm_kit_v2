# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  prepend_before_action { check_feature_enabled?(:user_omniauth) }
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  def twitter
    create
  end

  def google
    create
  end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  def after_omniauth_failure_path_for(scope)
    new_user_session_path
  end

  protected

  def create
    auth = request.env["omniauth.auth"]

    service = OmniauthAuthenticatorService.new(auth, current_user)
    service.run

    if service.event.present?
      flash[:notice] = I18n.t("devise.omniauth_callbacks.#{service.event}", kind: service.kind)

      if user_signed_in?
        redirect_to(authenticating_identities_path)
      else
        sign_in_and_redirect(service.identity.user, event: :authentication)
      end
    else
      flash[:notice] = I18n.t("devise.omniauth_callbacks.more_info")
      redirect_to(new_user_registration_url)
    end
  end
end
