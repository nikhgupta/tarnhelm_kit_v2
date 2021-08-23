# frozen_string_literal: true
require "test_helper"

class TarnhelmConfigTestCase < ActiveSupport::TestCase
  setup do
    @current = { name: ENV["TARNHELM_NAME"], host: ENV["TARNHELM_HOST"], ssl: ENV["TARNHELM_FORCE_SSL"] }
    ENV["TARNHELM_NAME"] = "test_kit"
    ENV["TARNHELM_HOST"] = "somedomain.test"
    ENV["TARNHELM_FORCE_SSL"] = "1"
  end

  teardown do
    ENV["TARNHELM_NAME"] = @current[:name]
    ENV["TARNHELM_HOST"] = @current[:host]
    ENV["TARNHELM_FORCE_SSL"] = @current[:ssl]

    ENV.delete("TARNHELM_DEFAULT_MAIL_FROM")
    ENV.delete("TARNHELM_GENERATED_EMAIL_DOMAIN")
  end

  context "app data" do
    should "provide app specific data from environment variables" do
      assert_equal Tarnhelm.app.name, "test_kit"
      assert_equal Tarnhelm.app.host, "somedomain.test"
      assert_equal Tarnhelm.app.force_ssl, true
      assert_equal Tarnhelm.app.default_mail_from, "test_kit <noreply@somedomain.test>"
      assert_equal Tarnhelm.app.generated_email_domain, "identity.users.somedomain.test"

      ENV["TARNHELM_FORCE_SSL"] = ""
      assert_equal Tarnhelm.app.force_ssl, false
      ENV.delete("TARNHELM_FORCE_SSL")
      assert_equal Tarnhelm.app.force_ssl, true
      ENV.delete("TARNHELM_FORCE_SSL")
      ENV["TARNHELM_HOST"] = "localhost.test"
      assert_equal Tarnhelm.app.force_ssl, false

      ENV["TARNHELM_GENERATED_EMAIL_DOMAIN"] = "another.test"
      assert_equal Tarnhelm.app.generated_email_domain, "another.test"

      ENV["TARNHELM_DEFAULT_MAIL_FROM"] = "test@localhost.test"
      assert_equal Tarnhelm.app.default_mail_from, "test@localhost.test"
    end
  end

  context "features" do
    should "provide an easy way to activate a feature" do
      Tarnhelm.activate_feature(:name, "Test feature", percentage: 20)

      record = Tarnhelm.feature_record_for(:name)
      info = Tarnhelm.get_feature_info(:name)
      assert_equal record.description, "Test feature"
      assert_equal info[:status], :partially_active
      assert_equal info[:status_humanized], "enabled for 20.00% actors"
      assert_equal info[:feature].percentage_of_actors_value, 20
    end

    should "provide a list of available features" do
      Tarnhelm.activate_feature(:name, "Test feature", percentage: 20)
      info = Tarnhelm.get_feature_info(:name)

      assert Tarnhelm.features_list.include?(info)
    end

    should "be disabled on errors when checking for their availability" do
      assert_equal Tarnhelm.active?({ ping: :pong }), false
      info = Tarnhelm.get_feature_info(:name)
      assert_nil info[:description]
      assert_equal info[:status], :inactive
      assert_equal info[:status_humanized], "disabled globally"
    end
  end

  context "#hash" do
    should "hash a given string to 64-char string by default" do
      str = "test string"
      hashed = Tarnhelm.hash(str)
      assert_equal hashed.length, 64
      assert_equal hashed, Tarnhelm.hash(str)
    end

    should "hash a given string to any given length" do
      str = "test string"
      hashed = Tarnhelm.hash(str, length: nil)
      assert_equal hashed, ""

      hashed = Tarnhelm.hash(str, length: 234)
      assert_equal hashed.length, 234
      assert_equal hashed, Tarnhelm.hash(str, length: 234)

      hashed1 = Tarnhelm.hash(str, length: 12000)
      hashed2 = Tarnhelm.hash(str, length: 12000)
      assert_equal hashed1.length, 12000
      assert_equal hashed1, hashed2
    end

    should "not contain shorter length hashes in higher length hashes" do
      str = "test string"
      hashed1 = Tarnhelm.hash(str, length: 64)
      hashed2 = Tarnhelm.hash(str, length: 65)
      refute hashed2.include?(hashed1)
    end
  end

  context "#hash_multi" do
    should "hash multiple strings together" do
      hash1 = Tarnhelm.hash("ping")
      hash2 = Tarnhelm.hash("pong")
      multi = Tarnhelm.hash_multi("ping", "pong")

      refute multi.include?(hash1)
      refute multi.include?(hash2)
      assert_equal multi.length, 128
    end

    should "hash to a given length if required" do
      hash1 = Tarnhelm.hash("ping", length: 80)
      hash2 = Tarnhelm.hash("pong", length: 80)
      other = Tarnhelm.hash_multi("ping", "pong", length: 80)
      multi = Tarnhelm.hash_multi("ping", "pong", length: 160)

      refute multi.include?(hash1)
      refute multi.include?(hash2)
      refute multi.include?(other)
      assert_equal other.length, 80
      assert_equal multi.length, 160
    end
  end

  context "#generate_secret_key" do
    should "provide the credentials if configured" do
      key = Tarnhelm.generate_secret_key(:base)
      assert_equal key, Rails.application.credentials.secret_key_base
      refute_equal key, Tarnhelm.generate_secret_key(:test)
    end

    should "generate a secret key if not configured" do
      key = Tarnhelm.generate_secret_key(:test)
      assert_equal key.length, 128
      assert_equal key, Tarnhelm.generate_secret_key(:test)
      refute_equal key, Tarnhelm.generate_secret_key(:base)
      refute_equal key, Tarnhelm.generate_secret_key(:ping)
    end
  end

  context "#generate_enc_key" do
    should "generate encryption keys from a given string" do
      key = Tarnhelm.generate_enc_key(:test)
      assert_equal key.length, 64
      assert_equal key, Tarnhelm.generate_enc_key(:test)
      refute_equal key, Tarnhelm.generate_enc_key(:base)
      refute_equal key, Tarnhelm.generate_enc_key(:ping)
      refute Tarnhelm.generate_secret_key(:test).include?(key)
    end
  end

  context "encode/decode" do
    should "use base64 by default" do
      str = "some string"
      refute_equal Tarnhelm.encode(str), str
      assert_equal Tarnhelm.decode(Tarnhelm.encode(str)), str
      assert_equal Base64.decode64(Tarnhelm.encode(str)), str
    end

    should "not decode data when invalid base is provided" do
      str = "some string"
      refute_equal Tarnhelm.decode(Tarnhelm.encode(str, base: 31)), @str
      refute_equal Tarnhelm.decode(Tarnhelm.encode(str), base: 31), @str
    end

    should "be differently encoded for different bases" do
      str = "some string"
      refute_equal Tarnhelm.encode(str, base: 32), Tarnhelm.encode(str, base: 33)
      refute_equal Tarnhelm.encode(str, base: 32), Tarnhelm.encode(str, base: 64)
    end

    should "raise error when invalid base is provided" do
      str = "some string"
      assert_raises { Tarnhelm.encode(str, base: 1) }
      assert_raises { Tarnhelm.encode(str, base: 37) }

      assert_raises { Tarnhelm.decode(str, base: 1) }
      assert_raises { Tarnhelm.decode(str, base: 37) }
    end

    should "use base64 by default"

    # base encode a string for base values till 36 and also on base 64
    def encode(str, base: 64)
      base == 64 ? Base64.encode64(str).gsub(/\s+/, "") : str.unpack1("H*").to_i(16).to_s(base)
    end

    # base decode a string for base values till 36 and also on base 64
    def decode(str, base: 36)
      base == 64 ? Base64.decode64(str) : [str.to_i(base).to_s(16)].pack("H*")
    end
  end

  context "encryption/decryption" do
    setup do
      @data = { ping: :pong }
      @expected = JSON.parse(@data.to_json)
    end

    context "normally" do
      should "encrypt/decrypt provided data with a given purpose" do
        decrypted = Tarnhelm.decrypt(Tarnhelm.encrypt(@data))
        assert_equal decrypted, @expected

        decrypted = Tarnhelm.decrypt(Tarnhelm.encrypt(@data, purpose: :other), purpose: :other)
        assert_equal decrypted, @expected
      end

      should "raise error when trying to decrypt with a wrong purpose" do
        assert_raises { Tarnhelm.decrypt(Tarnhelm.encrypt(@data), purpose: :other) }
        assert_raises { Tarnhelm.decrypt(Tarnhelm.encrypt(@data, purpose: :other)) }
      end

      should "only decrypt data before expiration" do
        encrypted = Tarnhelm.encrypt(@data, expires_at: 5.minutes.from_now)
        assert_equal Tarnhelm.decrypt(encrypted), @expected
        travel_to(7.minutes.from_now) { assert_nil Tarnhelm.decrypt(encrypted) }

        encrypted = Tarnhelm.encrypt(@data, expires_in: 5.minutes)
        assert_equal Tarnhelm.decrypt(encrypted), @expected
        travel_to(7.minutes.from_now) { assert_nil Tarnhelm.decrypt(encrypted) }
      end
    end

    context "for tokens" do
      should "encrypt data as a token to be used in URLs" do
        decrypted = Tarnhelm.decrypt_from_token(Tarnhelm.encrypt_as_token(@data))
        assert_equal decrypted, @expected

        decrypted = Tarnhelm.decrypt_from_token(Tarnhelm.encrypt_as_token(@data, purpose: :other), purpose: :other)
        assert_equal decrypted, @expected
      end

      should "not use same purpose for token encryption and other encryptions" do
        assert_raises { Tarnhelm.decrypt(Tarnhelm.encrypt_as_token(@data)) }
        assert_raises { Tarnhelm.decrypt_from_token(Tarnhelm.encrypt(@data)) }
      end

      should "only decrypt tokens before expiration" do
        token = Tarnhelm.encrypt_as_token(@data, expires_at: 5.minutes.from_now)
        assert_equal Tarnhelm.decrypt_from_token(token), @expected

        travel_to(7.minutes.from_now) { assert_nil Tarnhelm.decrypt_from_token(token) }
      end

      should "allow decryption upto a week by default" do
        token = Tarnhelm.encrypt_as_token(@data)
        assert_equal Tarnhelm.decrypt_from_token(token), @expected

        travel_to((1.week - 1.minute).from_now) { assert_equal Tarnhelm.decrypt_from_token(token), @expected }
        travel_to((1.week + 1.minute).from_now) { assert_nil Tarnhelm.decrypt_from_token(token) }
      end

      should "only decrypt tokens if they were created after a specific time" do
        token = Tarnhelm.encrypt_as_token(@data)
        assert_equal Tarnhelm.decrypt_from_token(token, after: 5.minutes.ago), @expected

        travel_to(7.minutes.ago) { token = Tarnhelm.encrypt_as_token(@data) }
        assert_nil Tarnhelm.decrypt_from_token(token, after: 5.minutes.ago)
      end
    end
  end
end
