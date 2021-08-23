# frozen_string_literal: true
OmniAuth.config.test_mode = true

# [:google, :twitter].each do |provider|
#   OmniAuth.config.mock_auth[provider] = Faker::Omniauth.send(provider).deep_merge(
#     provider: provider.to_s,
#     info: { image: "https://via.placeholder.com/50x50.png" }
#   )
# end

module ActiveSupport
  class TestCase
    def reset_omniauth_mock_for(provider)
      OmniAuth.config.mock_auth[provider] = Faker::Omniauth.send(provider).deep_merge(
        provider: provider.to_s,
        info: { image: "https://via.placeholder.com/50x50.png" }
      )
    end
  end
end
