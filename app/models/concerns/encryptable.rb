# frozen_string_literal: true
module Encryptable
  extend ActiveSupport::Concern

  included do
    unless delegates_salt?
      after_initialize :generate_row_level_salt
      before_validation :generate_row_level_salt
      validates :salt, presence: true, uniqueness: true
    end
  end

  class_methods do
    def delegates_salt?
      !column_names.include?("salt")
    end
  end

  def delegates_salt?
    self.class.delegates_salt?
  end

  def encryption_key
    Tarnhelm.generate_enc_key(useable_salt)
  end

  def secret_key
    Tarnhelm.generate_secret_key(useable_salt)
  end

  def useable_salt
    Tarnhelm.hash_multi(
      Tarnhelm.hash(salt),
      Tarnhelm.hash(salt, key: :encryption)
    )
  end

  def generate_row_level_salt
    return if delegates_salt? || salt.present?
    self.salt = SecureRandom.alphanumeric(128)
  end

  def update_salt!(str)
    return if self.class.delegates_salt?

    if self.class.respond_to?(:lockbox_attributes)
      attrs = self.class.lockbox_attributes.keys
      attrs = attrs.map { |f| [f, send(f)] }.to_h
      self.salt = str
      update(attrs.merge(salt: str))
    else
      update(salt: str)
    end
  end

  class_methods do
    def encrypts_each_row_of(*fields, **kwargs)
      fields.each do |field|
        encrypts(field, key: :encryption_key, **kwargs)
      end
    end
  end
end
