FactoryBot.define do
  factory :wallet do
    association :user
    balance { 1000.00 }

    trait :with_high_balance do
      balance { 10000.00 }
    end

    trait :with_low_balance do
      balance { 100.00 }
    end

    trait :empty do
      balance { 0.00 }
    end
  end
end
