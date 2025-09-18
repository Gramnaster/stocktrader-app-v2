# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_18_032443) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "transaction_type", ["buy", "sell"]
  create_enum "user_role", ["trader", "admin"]
  create_enum "user_status", ["pending", "approved", "rejected"]

  create_table "countries", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "historical_prices", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.date "date", null: false
    t.decimal "previous_close", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id", "date"], name: "index_historical_prices_on_stock_id_and_date", unique: true
    t.index ["stock_id"], name: "index_historical_prices_on_stock_id"
  end

  create_table "portfolios", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stock_id", null: false
    t.decimal "quantity", precision: 15, scale: 5, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_portfolios_on_stock_id"
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "stock_reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stock_id", null: false
    t.boolean "vote", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_stock_reviews_on_stock_id"
    t.index ["user_id", "stock_id"], name: "index_stock_reviews_on_user_id_and_stock_id", unique: true
    t.index ["user_id"], name: "index_stock_reviews_on_user_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.string "exchange"
    t.string "ticker", null: false
    t.string "name", null: false
    t.string "web_url"
    t.string "logo_url"
    t.decimal "current_price", precision: 15, scale: 2
    t.decimal "daily_change", precision: 15, scale: 2
    t.decimal "percent_daily_change", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency", null: false
    t.index ["country_id"], name: "index_stocks_on_country_id"
    t.index ["ticker"], name: "index_stocks_on_ticker", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stock_id", null: false
    t.enum "transaction_type", null: false, enum_type: "transaction_type"
    t.decimal "quantity", precision: 15, scale: 5, null: false
    t.decimal "price_per_share", precision: 15, scale: 2, null: false
    t.decimal "total_amount", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_transactions_on_stock_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name", null: false
    t.string "middle_name"
    t.string "last_name", null: false
    t.date "date_of_birth", null: false
    t.string "mobile_no", null: false
    t.string "address_line_01"
    t.string "address_line_02"
    t.string "city"
    t.string "zip_code", null: false
    t.bigint "country_id", null: false
    t.enum "user_status", default: "pending", null: false, enum_type: "user_status"
    t.enum "user_role", default: "trader", null: false, enum_type: "user_role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["mobile_no"], name: "index_users_on_mobile_no", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_role"], name: "index_users_on_user_role"
    t.index ["user_status", "user_role"], name: "index_users_on_user_status_and_user_role"
    t.index ["user_status"], name: "index_users_on_user_status"
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "balance", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "historical_prices", "stocks"
  add_foreign_key "portfolios", "stocks"
  add_foreign_key "portfolios", "users"
  add_foreign_key "stock_reviews", "stocks"
  add_foreign_key "stock_reviews", "users"
  add_foreign_key "stocks", "countries"
  add_foreign_key "transactions", "stocks"
  add_foreign_key "transactions", "users"
  add_foreign_key "users", "countries"
  add_foreign_key "wallets", "users"
end
