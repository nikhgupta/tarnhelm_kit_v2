# frozen_string_literal: true
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password" }
    password_confirmation { password }

    after(:build, &:skip_confirmation!)
  end
end
