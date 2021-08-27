# frozen_string_literal: true
require "application_system_test_case"

class UserCreatesNewAccountTest < ApplicationSystemTestCase
  attr_reader :user

  context "with accounts enabled for user" do
    setup do
      Flipper.enable(:user_magic_links)
      @user = create(:user)
      Flipper.enable(:user_accounts, @user)
      sign_in_as user.email
    end

    should "allow user to create a new account" do
      account = create(:account)
      user.accounts << account

      visit root_url
      find("#user-menu").click
      assert_link "Personal Account"

      click_on "Add new account"
      fill_in "Name", with: "Test Account"

      click_on "Create Account"
      assert_flash notice: "Account was successfully created."

      record = Account.last
      assert_link user.email
      assert_equal page.current_url, account_url(record)

      assert_equal record.name, "Test Account"
      assert user.accounts.impersonal.include?(record)
      assert record.users.include?(user)

      assert_user_can_switch_to_account name: record.name

      visit edit_user_registration_url
      assert_link record.name, href: account_path(record)
    end

    should "not allow an account with failed validations" do
      visit root_url
      find("#user-menu").click
      assert_link "Personal Account"

      click_on "Add new account"
      fill_in "Name", with: "    "
      click_on "Create Account"

      assert_flash alert: "Name can't be blank"
      assert_equal Account.count, 1
    end
  end
end
