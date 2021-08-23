# frozen_string_literal: true

module Tarnhelm
  # =================================================================================
  # WARNING: DO NOT CHANGE CODE IN THIS FILE IF YOU ALREADY HAVE SOME PRODUCTION DATA
  # =================================================================================
  #
  #          This code is used to generate encryption and secret keys on the fly.
  #          Once you have production data, changing code in this file can result
  #          in data that is inconsistent or not decryptable anymore.
  #
  # =================================================================================
  module Cryptography
    # get a secret key from our credentials
    def secret(key = :base)
      Rails.application.credentials["secret_key_#{key}".to_sym]
    end

    # hash a given string to an arbitrary length
    # - iterative
    # - use a salt at each step (fixed str and result of previous step)
    # - optionally, provide a block to modify the algorithm at each step
    def hash(str, length: 64, key: :base)
      hashed = []
      n = length.to_i < 64 ? 4 : (length * 2) / 64 + 3

      n.times do
        str = "#{str}-#{length}-#{secret(key)}-#{hashed.last || secret(key)}"
        str = Digest::SHA2.hexdigest(str)
        str = yield(str) if block_given?
        str = Digest::SHA2.hexdigest(str)
        hashed << str
      end

      hashed.join[0...length.to_i]
    end

    # hash multiple strings to generate a hash string
    def hash_multi(*strings, **kwargs)
      hashed = strings.map do |str|
        str = Tarnhelm.hash(str, **kwargs)
        str = yield(str) if block_given?
        Tarnhelm.hash(str, **kwargs)
      end

      kwargs[:length].to_i.positive? ? hashed.join[0...kwargs[:length].to_i] : hashed.join
    end

    # generate a secret key on the fly (length = 128)
    # - if secret key is defined in credentails.yaml, use that
    # - otherwise, generate it from the hash algorithm above
    def generate_secret_key(str, length: 128)
      secret(str) || hash(str.to_s, length: length, key: :base)
    end

    # generate an encryption key on the fly (length = 32)
    def generate_enc_key(str, length: 64)
      hash(str.to_s, length: length, key: :encryption)
    end

    # encryptor which uses a `purpose` to define secret and
    # signing secret on the fly
    def encryptor(purpose = :encryption)
      key = generate_enc_key(purpose, length: 32)
      sign = generate_secret_key(purpose)
      ActiveSupport::MessageEncryptor.new(key, sign, serializer: JSON)
    end

    # encrypt a string with a given purpose and optionally,
    # expires_in or expires_at arguments
    def encrypt(data, purpose: :encryption, expires_in: nil, expires_at: nil)
      data = { data: data }
      expires_at ||= expires_in.from_now if expires_in.present?
      data[:expires_at] = expires_at.to_i if expires_at.present?
      encryptor(purpose).encrypt_and_sign(data)
    end

    # decrypt a string with a given purpose
    def decrypt(str, purpose: :encryption)
      data = encryptor(purpose).decrypt_and_verify(str)
      data["data"] if data["expires_at"].blank? || data["expires_at"].to_i >= Time.current.to_i
    end

    # encrypt given data to be used as a token in URLs
    def encrypt_as_token(data, purpose: :token, expires_in: 1.week, expires_at: nil)
      data = { data: data, created_at: Time.current.to_i }
      encrypt(data, purpose: purpose, expires_in: expires_in, expires_at: expires_at)
    end

    # decrypt token in URLs to get the underlying data
    def decrypt_from_token(str, purpose: :token, after: nil)
      data = decrypt(str, purpose: purpose)
      return if data.blank? || (after.present? && data["created_at"] < after.to_i)

      data["data"]
    end

    # base encode a string for base values till 36 and also on base 64
    def encode(str, base: 64)
      base == 64 ? Base64.encode64(str).gsub(/\s+/, "") : str.unpack1("H*").to_i(16).to_s(base)
    end

    # base decode a string for base values till 36 and also on base 64
    def decode(str, base: 64)
      base == 64 ? Base64.decode64(str) : [str.to_i(base).to_s(16)].pack("H*")
    end
  end
end
