# frozen_string_literal: true
require "application_system_test_case"

class UserSwitchesAccountTest < ApplicationSystemTestCase
  attr_reader :user
  context "with accounts enabled for user" do
    setup do
      Flipper.enable(:user_magic_links)
      @user = create(:user)
      Flipper.enable(:user_accounts, @user)
    end

    should "allow user to switch to another account" do
      account = create(:account)
      user.accounts << account

      sign_in_as(user.email)

      assert_user_can_switch_to_account show_flash: false
      assert_user_can_switch_to_account name: account.name
      assert_user_can_switch_to_account
    end
  end
end
