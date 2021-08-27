# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  set_current_tenant_through_filter
  before_action :find_current_tenant
  helper_method :current_account

  def find_current_tenant
    set_current_tenant(current_account)
  end

  def current_user
    super || nil
  end

  def current_account
    return nil if current_user.blank?
    current_user.account_with(session[:account_id]) || current_user.personal_account
  end

  protected

  def not_found
    path = request.env["PATH_INFO"]
    method = request.env["REQUEST_METHOD"]
    message = "No route matches [#{method}] \"#{path}\""
    raise ActionController::RoutingError, message
  end

  def check_feature_enabled?(feature)
    return if current_user&.enabled?(feature)
    return if Tarnhelm.active?(feature)

    not_found
  end

  def auth_enabled?
    return if Tarnhelm.active?(:user_passwords)
    return if Tarnhelm.active?(:user_magic_links)
    return if Tarnhelm.active?(:user_omniauth)

    not_found
  end
end
