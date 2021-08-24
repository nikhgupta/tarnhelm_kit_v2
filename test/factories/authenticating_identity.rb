# frozen_string_literal: true
FactoryBot.define do
  factory :authenticating_identity do
    user

    provider { "google" }
    uid { Faker::Number.unique.number(digits: 10) }

    token { "token" }
    email { "private@example.com" }
    refresh_token { "refresh_token" }
    auth_data { { a: :b } }
  end
end
