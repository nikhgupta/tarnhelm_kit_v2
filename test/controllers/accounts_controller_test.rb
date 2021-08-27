# frozen_string_literal: true
require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup { Flipper.enable(:user_passwords) }

  context "unauthenticated request" do
    should "not get index" do
      get accounts_url
      assert_redirected_to new_user_session_url
    end

    should "not get new" do
      get new_account_url
      assert_redirected_to new_user_session_url
    end

    should "not create account" do
      post accounts_url, params: { account: { name: "Test Account" } }
      assert_redirected_to new_user_session_url
    end

    should "not show account" do
      account = create(:account)
      get account_url(account)
      assert_redirected_to new_user_session_url
    end
  end

  should "show not found error when user accounts are disabled" do
    user = create(:user)
    account = create(:account)
    user.accounts << account

    sign_in user
    get root_path
    assert_response :success

    assert_routes_disabled :accounts, :new_account, account_path(account)
    assert_routes_disabled :accounts, switch_account_path(account), method: :post
    assert_routes_disabled account_path(account), method: [:put, :patch, :delete]
  end

  context "user with multiple accounts" do
    setup do
      @user = create(:user)
      Flipper.enable(:user_accounts, @user)

      @account = create(:account)
      @user.accounts << @account

      sign_in @user
    end

    should "get index" do
      get accounts_url
      assert_response :success
    end

    should "get new" do
      get new_account_url
      assert_response :success
    end

    should "create account" do
      assert_difference("Account.count") do
        post accounts_url, params: { account: { name: "Test Account" } }
      end

      assert_redirected_to account_url(Account.last)
      assert Account.last.users.include?(@user)
    end

    should "show account" do
      get account_url(@account)
      assert_response :success
    end
  end

  # should "get edit" do
  #   get edit_account_url(@account)
  #   assert_response :success
  # end

  # should "update account" do
  #   patch account_url(@account), params: { account: {} }
  #   assert_redirected_to account_url(@account)
  # end

  # should "destroy account" do
  #   assert_difference("Account.count", -1) do
  #     delete account_url(@account)
  #   end

  #   assert_redirected_to accounts_url
  # end
end
