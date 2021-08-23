# frozen_string_literal: true
require "test_helper"

class UserTest < ActiveSupport::TestCase
  attr_reader :user, :magic

  setup do
    @user = FactoryBot.create(:user)
    @magic = FactoryBot.create(:user, password: nil)
  end

  context "associations" do
    should have_many(:authenticating_identities)
  end

  context "validations" do
    should "validate confirmation of password" do
      assert user.valid?

      user.password = ""
      user.password_confirmation = "wrong-confirmation"
      assert user.valid?

      user.password = "password"
      user.password_confirmation = "wrong-confirmation"
      assert user.invalid?
    end
  end

  test "checks whether user login using password" do
    refute user.requires_magic_link?
    assert user.can_login_using_password?

    disable_feature :user_passwords
    assert user.requires_magic_link?
    refute user.can_login_using_password?

    disable_feature :user_magic_links
    refute user.requires_magic_link?
    refute user.can_login_using_password?
  end

  test "checks whether user can only login with magic link" do
    assert magic.requires_magic_link?
    refute magic.can_login_using_password?

    disable_feature :user_magic_links
    refute user.requires_magic_link?
    assert user.can_login_using_password?

    disable_feature :user_passwords
    refute user.requires_magic_link?
    refute user.can_login_using_password?
  end

  test "#generated_email?" do
    assert_equal user.generated_email?, false

    user.email = "something@#{Tarnhelm.app.generated_email_domain}"
    assert_equal user.generated_email?, true
  end

  test "finds an #authenticating_identity_for a given provider" do
    auth = user.authenticating_identities.create(provider: "test", uid: "123")

    assert_equal user.authenticating_identity_for(:test), auth
    assert_nil user.authenticating_identity_for(:something_else)
  end

  test "can find internal users easily" do
    FactoryBot.create(:user, email: "test@otherdomain123.com")
    assert_nil User.internal(:demo)
    assert_nil User.internal(:test)

    demo = FactoryBot.create(:user, email: "demo@#{Tarnhelm.app.host}")
    assert_equal User.internal(:demo), demo
  end

  test "it adds a unique salt, encryption and secret key for each record" do
    id1, id2 = FactoryBot.build_list(:user, 2)

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
