FactoryBot.define do
  factory :receipt do
    user { nil }
    stock { nil }
    quantity { "9.99" }
    price_per_share { "9.99" }
    total_amount { "MyString" }
    decimal { "MyString" }
  end
end
