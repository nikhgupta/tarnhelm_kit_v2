# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
end
