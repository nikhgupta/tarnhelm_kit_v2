# frozen_string_literal: true

require_relative "tarnhelm/crypto"
require_relative "tarnhelm/feature"

module Tarnhelm
  class << self
    include Tarnhelm::Feature
    include Tarnhelm::Cryptography

    def app
      res = OpenStruct.new(name: ENV["TARNHELM_NAME"], real_host: ENV["TARNHELM_HOST"])
      res.host, res.port = res.real_host.split(":")
      res.default_url_options = { host: res.host }
      res.default_url_options[:port] = res.port if res.port.present?
      res.force_ssl = ENV.fetch("TARNHELM_FORCE_SSL", localhost?(res)).present?
      res.default_mail_from = ENV.fetch("TARNHELM_DEFAULT_MAIL_FROM", "#{res.name} <noreply@#{res.host}>")
      res.generated_email_domain = ENV.fetch("TARNHELM_GENERATED_EMAIL_DOMAIN", "identity.users.#{res.host}")
      res
    end

    # NOTE: DO NOT change this method - as this method is also used in tests.
    #       If you want to change feature states, please use the Flipper UI.
    def activate_initial_features!
      activate_feature(:user_passwords, "Users can set/use passwords for authentication.")
      activate_feature(:user_registrations, "Users can register themselves on this site.")
      activate_feature(:user_magic_links, "Users can use magic links for authentication.")
      activate_feature(:user_omniauth, "Users can use social identities for authentication.")
      activate_feature(:user_invitations, "Users can invite other users")
    end

    private

    def localhost?(res)
      res.host unless res.host =~ /(localhost|lvh\.me|localhost.test)\z/
    end
  end
end
