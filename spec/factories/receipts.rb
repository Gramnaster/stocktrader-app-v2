FactoryBot.define do
  factory :receipt do
    association :user
    association :stock
    transaction_type { "buy" }
    quantity { 10.0 }
    price_per_share { 100.0 }
    total_amount { 1000.0 }

    trait :sell_transaction do
      transaction_type { "sell" }
    end

    trait :large_quantity do
      quantity { 100.0 }
      total_amount { 10000.0 }
    end
  end
end
