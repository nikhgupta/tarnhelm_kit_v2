# frozen_string_literal: true
module Encryptable
  extend ActiveSupport::Concern

  included do
    after_initialize :generate_row_level_salt
    validates :salt, presence: true, uniqueness: true
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
    return if salt.present?
    self.salt = SecureRandom.alphanumeric(128)
  end

  def update_salt!(str)
    attrs = self.class.lockbox_attributes.keys
    attrs = attrs.map { |f| [f, send(f)] }.to_h
    update(attrs.merge(salt: str))
  end

  class_methods do
    def encrypts_each_row_of(*fields, **kwargs)
      fields.each do |field|
        encrypts(field, key: :encryption_key, **kwargs)
      end
    end
  end
end
