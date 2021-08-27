# frozen_string_literal: true
require "test_helper"
require_relative "concerns/encryptable_test"

class AccountTest < ActiveSupport::TestCase
  include EncryptableTest
  should_encrypt_attributes

  subject { build(:account) }

  should have_many(:memberships).dependent(:destroy)
  should have_many(:users).through(:memberships)
  should validate_presence_of(:name)

  should "provide display name for UI" do
    record = create(:account)
    assert_equal record.display_name, record.name

    record = create(:personal_account)
    assert_equal record.display_name, "Personal Account"
  end

  should "provide scopes for seggregating personal and impersonal accounts" do
    list1 = create_list(:account, 2)
    list2 = create_list(:personal_account, 2)

    assert_same_elements list2, Account.personal
    assert_same_elements list1, Account.impersonal
  end

  context "with accounts enabled" do
    should "create personal account" do
      Flipper.enable(:user_accounts)
      user = create(:user)
      assert_equal user.accounts.length, 1
      assert user.accounts.first.personal?
    end
  end

  context "with accounts disabled" do
    should "create personal account" do
      user = create(:user)
      assert_equal user.accounts.length, 1
      assert user.accounts.first.personal?
    end
  end
end
