FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@reservaya.test" }
    password { "secret123" }
    role { :user }

    trait :admin do
      role { :admin }
    end
  end
end
