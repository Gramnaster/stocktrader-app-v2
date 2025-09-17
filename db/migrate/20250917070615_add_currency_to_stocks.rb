class AddCurrencyToStocks < ActiveRecord::Migration[8.0]
  def change
    add_column :stocks, :currency, :string, null: false
  end
end
