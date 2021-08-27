# frozen_string_literal: true
FactoryBot.define do
  factory :account do
    name { Faker::Company.unique.name }
    personal { false }

    factory :personal_account do
      personal { true }
    end
  end
end
