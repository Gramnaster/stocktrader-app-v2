FactoryBot.define do
  factory :stock do
    association :country
    exchange { "NASDAQ" }
    ticker { "AAPL" }
    name { "Apple Inc." }
    web_url { "https://apple.com" }
    logo_url { "https://logo.clearbit.com/apple.com" }
    current_price { 150.25 }
    daily_change { 2.50 }
    percent_daily_change { 1.69 }
    currency { "USD" }
    market_cap { 2500000000 }

    trait :expensive do
      current_price { 500.00 }
    end

    trait :cheap do
      current_price { 10.00 }
    end
  end
end
