# frozen_string_literal: true
require "test_helper"
require_relative "concerns/encryptable_test"

class MembershipTest < ActiveSupport::TestCase
  include EncryptableTest
  should_encrypt_attributes

  subject { create(:membership) }

  should belong_to(:user)
  should belong_to(:account)
  should belong_to(:invitee).class_name("User").with_foreign_key(:invited_by_id).optional

  should validate_uniqueness_of(:user_id).scoped_to(:account_id).case_insensitive

  should "use salt, encryption and secret key from account" do
    assert_equal subject.salt, subject.account.salt
    assert_equal subject.useable_salt, subject.account.useable_salt
    assert_equal subject.encryption_key, subject.account.encryption_key
    assert_equal subject.secret_key, subject.account.secret_key
  end
end
