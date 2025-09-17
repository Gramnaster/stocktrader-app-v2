class CreateStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks do |t|
      t.references :country, null: false, foreign_key: true
      t.string :exchange
      t.string :ticker,                 null: false
      t.string :name,                   null: false
      t.string :web_url
      t.string :logo_url
      t.decimal :current_price, precision: 15, scale: 2
      t.decimal :daily_change, precision: 15, scale: 2
      t.decimal :percent_daily_change, precision: 15, scale: 2

      t.timestamps
    end

    add_index :stocks, :ticker, unique: true
  end
end
