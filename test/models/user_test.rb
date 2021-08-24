# frozen_string_literal: true
require "test_helper"
require_relative "concerns/encryptable_test"

class UserTest < ActiveSupport::TestCase
  attr_reader :magic

  include EncryptableTest
  should_encrypt_attributes

  subject { create(:user) }
  setup { @magic = create(:user, password: nil) }

  should have_one_attached(:avatar)
  should have_many(:authenticating_identities).dependent(:destroy)
  context "validations" do
    should "validate confirmation of password" do
      assert subject.valid?

      subject.password = ""
      subject.password_confirmation = "wrong-confirmation"
      assert subject.valid?

      subject.password = "password"
      subject.password_confirmation = "wrong-confirmation"
      assert subject.invalid?
    end
  end

  should "have a person name" do
    subject.first_name = "Test"
    subject.last_name = "User"
    assert_equal subject.name, "Test User"

    subject.name = "Another User 2"
    assert_equal subject.first_name, "Another"
    assert_equal subject.last_name, "User 2"

    subject.name = ""
    assert_nil subject.first_name
    assert_nil subject.last_name

    subject.name = nil
    assert_nil subject.first_name
    assert_nil subject.last_name
  end

  should "check whether subject login using password" do
    refute subject.requires_magic_link?
    assert subject.can_login_using_password?

    disable_feature :user_passwords
    assert subject.requires_magic_link?
    refute subject.can_login_using_password?

    disable_feature :user_magic_links
    refute subject.requires_magic_link?
    refute subject.can_login_using_password?
  end

  should "check whether subject can only login with magic link" do
    assert magic.requires_magic_link?
    refute magic.can_login_using_password?

    disable_feature :user_magic_links
    refute subject.requires_magic_link?
    assert subject.can_login_using_password?

    disable_feature :user_passwords
    refute subject.requires_magic_link?
    refute subject.can_login_using_password?
  end

  should "provide a check for #generated_email?" do
    assert_equal subject.generated_email?, false

    subject.email = "something@#{Tarnhelm.app.generated_email_domain}"
    assert_equal subject.generated_email?, true
  end

  should "find an #authenticating_identity_for a given provider" do
    auth = subject.authenticating_identities.create(provider: "test", uid: "123")

    assert_equal subject.authenticating_identity_for(:test), auth
    assert_nil subject.authenticating_identity_for(:something_else)
  end

  should "find internal subjects easily" do
    create(:user, email: "test@otherdomain123.com")
    assert_nil User.internal(:demo)
    assert_nil User.internal(:test)

    demo = create(:user, email: "demo@#{Tarnhelm.app.host}")
    assert_equal User.internal(:demo), demo
  end

  should "confirm a user #after_magic_link_authentication" do
    subject.confirmed_at = nil
    subject.unconfirmed_email = subject.email
    subject.save

    refute subject.confirmed?

    subject.after_magic_link_authentication
    assert subject.confirmed?
  end

  should "add a unique salt, encryption and secret key for each record" do
    id1, id2 = build_list(:user, 2)

    assert_equal id1.salt.length, 128
    assert_equal id2.salt.length, 128
    refute_equal id1.salt, id2.salt

    assert_equal id1.useable_salt, id1.useable_salt
    refute_equal id1.useable_salt, id2.useable_salt

    assert_equal id1.encryption_key.length, 64
    assert_equal id2.encryption_key.length, 64
    assert_equal id1.encryption_key, id1.encryption_key
    refute_equal id1.encryption_key, id2.encryption_key

    assert_equal id1.secret_key.length, 128
    assert_equal id2.secret_key.length, 128
    assert_equal id1.secret_key, id1.secret_key
    refute_equal id1.secret_key, id2.secret_key
  end
end
