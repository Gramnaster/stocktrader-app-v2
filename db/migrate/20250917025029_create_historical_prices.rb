class CreateHistoricalPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :historical_prices do |t|
      t.references :stock, null: false, foreign_key: true
      t.date :date,        null: false
      t.decimal :previous_close, precision: 15, scale: 2

      t.timestamps
    end

    add_index :historical_prices, [ :stock_id, :date ], unique: true
  end
end
