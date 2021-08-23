# frozen_string_literal: true
class AuthenticatingIdentitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_authenticating_identity, only: [:destroy]

  def index
    @identities = current_user.authenticating_identities.where(provider: User.omniauth_providers).load

    @missing = User.omniauth_providers.map do |provider|
      next if @identities.map(&:provider).include?(provider.to_s)
      current_user.authenticating_identities.new(provider: provider)
    end.compact
  end

  def destroy
    @authenticating_identity.destroy

    respond_to do |format|
      format.html { redirect_to(authenticating_identities_path, notice: "Authentication was successfully destroyed.") }
      format.json { head(:no_content) }
    end
  end

  private

  def set_authenticating_identity
    @authenticating_identity = current_user.authenticating_identities.find(params[:id])
  end
end
