FactoryBot.define do
  factory :portfolio do
    association :user
    association :stock
    quantity { 10.0 }

    trait :empty do
      quantity { 0.0 }
    end

    trait :large_position do
      quantity { 100.0 }
    end
  end
end
