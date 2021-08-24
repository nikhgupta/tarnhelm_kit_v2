# frozen_string_literal: true
module EncryptableTest
  extend ActiveSupport::Concern
  include Shoulda::Context::DSL

  class_methods do
    attr_reader :encrypted_fields

    def should_encrypt_attributes(*fields)
      @encrypted_fields = fields
    end

    def model
      name.gsub(/Test\z/, "").constantize
    end

    def factory_name
      model.name.underscore
    end
  end

  context("model having encrypted attributes") do
    subject { create(self.class.factory_name) }

    should("generates a salt for each row") do
      assert(subject.salt.present?)
      assert_equal(subject.salt.length, 128)
      assert(subject.salt.match?(/[a-z0-9]+/i))
    end

    should("validate for salts to be unique") do
      skip if self.class.model.delegates_salt?

      other = build(self.class.factory_name, salt: subject.salt)
      other.save
      refute(other.persisted?)
      assert(other.errors.full_messages.include?("Salt has already been taken"))

      other.salt = nil
      other.save
      assert(other.persisted?)
      refute_equal(subject.salt, other.salt)
    end

    should("provide an intermediate salt for use") do
      assert(subject.useable_salt.present?)
      assert_equal(subject.useable_salt.length, 128)
      refute_equal(subject.useable_salt, subject.salt)
      assert_equal(subject.useable_salt, subject.useable_salt)

      next if subject.delegates_salt?
      current = subject.useable_salt
      subject.salt = "something else"
      refute_equal(current, subject.useable_salt)
      assert_equal(subject.useable_salt.length, 128)
    end

    should("provide an encryption key based on salt") do
      assert(subject.encryption_key.present?)
      assert_equal(subject.encryption_key.length, 64)
      refute_equal(subject.encryption_key, subject.salt)
      refute_equal(subject.encryption_key, subject.useable_salt)
      assert_equal(subject.encryption_key, subject.encryption_key)

      next if subject.delegates_salt?
      current = subject.encryption_key
      subject.salt = "something else"
      refute_equal(current, subject.encryption_key)
      assert_equal(subject.encryption_key.length, 64)
    end

    should("provide a secret key based on salt") do
      assert(subject.secret_key.present?)
      assert_equal(subject.secret_key.length, 128)
      refute_equal(subject.secret_key, subject.salt)
      refute_equal(subject.secret_key, subject.useable_salt)
      assert_equal(subject.secret_key, subject.secret_key)

      next if subject.delegates_salt?
      current = subject.secret_key
      subject.salt = "something else"
      refute_equal(current, subject.secret_key)
      assert_equal(subject.secret_key.length, 128)
    end

    should("encrypt the data in database") do
      skip if self.class.encrypted_fields.blank?
      self.class.encrypted_fields.each do |column|
        assert_raises { self.class.model.where(id: subject.id).pluck(:salt, column) }
        val = subject.send(column)
        cip = subject.send("#{column}_ciphertext")
        assert(val.present?)
        refute_equal(val, cip)
        assert(cip.match?(%r{\A[a-z0-9=\+/]+\z}i))
      end
    end

    should("make data un-decryptable on changing the salt") do
      skip if self.class.encrypted_fields.blank?
      subject.update(salt: "whatever")

      record = self.class.model.find(subject.id)
      assert_raises(Lockbox::DecryptionError) { record.attributes }
    end

    should("allow #update_salt! to be used for safely updating the salt") do
      skip if subject.delegates_salt?

      if self.class.encrypted_fields.blank?
        subject.update_salt!("whatever")
        assert_equal subject.salt, "whatever"
      else
        current = self.class.encrypted_fields.map { |f| [f, subject.send(f)] }.to_h
        subject.update_salt!("whatever")

        record = self.class.model.find(subject.id)
        self.class.encrypted_fields.each do |field|
          assert_equal(record.send(field), current[field])
        end
      end
    end
  end
end
