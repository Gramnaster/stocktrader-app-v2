FactoryBot.define do
  factory :user do
    association :country
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { "John" }
    last_name { "Doe" }
    date_of_birth { Date.new(1990, 1, 1) }
    mobile_no { "1234567890" }
    address_line_01 { "123 Main St" }
    city { "New York" }
    zip_code { "10001" }
    user_status { "approved" }
    user_role { "trader" }
    confirmed_at { Time.current }
  end
end
