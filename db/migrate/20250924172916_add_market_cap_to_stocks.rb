class AddMarketCapToStocks < ActiveRecord::Migration[8.0]
  def up
    add_column :stocks, :market_cap, :decimal, precision: 20, scale: 2, default: 0.0
    Stock.update_all(market_cap: 0.0)
    change_column_null :stocks, :market_cap, false
  end

  def down
    remove_column :stocks, :market_cap
  end
end
