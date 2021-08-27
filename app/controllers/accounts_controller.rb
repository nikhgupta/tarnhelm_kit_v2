# frozen_string_literal: true
class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, except: [:index]
  prepend_before_action { check_feature_enabled?(:user_accounts) }

  # GET /accounts or /accounts.json
  def index
    @accounts = current_user.accounts
  end

  # GET /accounts/1 or /accounts/1.json
  def show
  end

  def switch
    current = current_account
    session[:account_id] = @resource.try(:id) || current_user.personal_account.id
    if @resource.present? && @resource != current
      flash[:notice] = "Switched to #{@resource.personal? ? "your personal account." : "#{@resource.name}'s account."}"
    end
    redirect_to(root_path)
    # redirect_to(account_path(@resource ? @resource : current_user.personal_account))
  end

  # GET /accounts/new
  def new
    @resource = current_user.accounts.new
  end

  # POST /accounts or /accounts.json
  def create
    @resource = Account.new(account_params.merge(personal: false))

    respond_to do |format|
      if @resource.save
        @resource.users << current_user
        format.html { redirect_to(account_path(@resource), notice: "Account was successfully created.") }
        format.json { render(:show, status: :created, location: @account) }
      else
        format.html { render(:new, status: :unprocessable_entity) }
        format.json { render(json: @resource.errors, status: :unprocessable_entity) }
      end
    end
  end

  # # GET /accounts/1/edit
  # def edit
  # end

  # # PATCH/PUT /accounts/1 or /accounts/1.json
  # def update
  #   respond_to do |format|
  #     if @resource.update(account_params)
  #       format.html { redirect_to(@account, notice: "Account was successfully updated.") }
  #       format.json { render(:show, status: :ok, location: @resource) }
  #     else
  #       format.html { render(:edit, status: :unprocessable_entity) }
  #       format.json { render(json: @resource.errors, status: :unprocessable_entity) }
  #     end
  #   end
  # end

  # # DELETE /accounts/1 or /accounts/1.json
  # def destroy
  #   @resource.destroy
  #   respond_to do |format|
  #     format.html { redirect_to(accounts_url, notice: "Account was successfully destroyed.") }
  #     format.json { head(:no_content) }
  #   end
  # end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @resource = current_user.account_with(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def account_params
    params.fetch(:account, {}).permit(:name)
  end
end
