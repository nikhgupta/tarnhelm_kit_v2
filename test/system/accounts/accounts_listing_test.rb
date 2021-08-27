# frozen_string_literal: true
require "application_system_test_case"

class AccountsListingTest < ApplicationSystemTestCase
  attr_reader :user, :account

  setup do
    Flipper.enable(:user_magic_links)

    @user = create(:user)
    @account = create(:account, name: "Test Account")
    user.accounts << account
    sign_in_as(user.email)
  end

  context "accounts are disabled by default" do
    should "404 listing of accounts" do
      visit root_url
      find("#user-menu").click
      assert_link "Edit Account"
      assert_link "Logout"
      assert_no_link "Personal Account"
      assert_no_link "Your accounts"
    end

    should "not display acccounts link on profile page" do
      visit edit_user_registration_url
      assert_link "Edit Profile"
      assert_no_link "Your Accounts"
      assert_no_link "Test Account"
    end

    should "not display acccounts on delete my data page" do
      visit user_delete_data_url
      assert_no_content "Test Account"
    end
  end

  context "with accounts enabled for the user" do
    setup { Flipper.enable(:user_accounts, user) }

    should "list accounts for a user" do
      visit root_url
      find("#user-menu").click
      assert_link "Edit Account"
      assert_link "Logout"
      assert_link "Personal Account"

      click_on "Your accounts"
      assert_link account.name, href: account_path(account)
      assert_link "Personal Account", href: account_path(user.personal_account)
      assert_link "Create another Account", href: new_account_path
    end

    should "display acccounts link on profile page" do
      visit edit_user_registration_url
      assert_link "Edit Profile"
      assert_link "Your Accounts"
      assert_link "Test Account"
    end

    should "display acccounts on delete my data page" do
      visit user_delete_data_url
      assert_content "Test Account"
    end
  end
end
