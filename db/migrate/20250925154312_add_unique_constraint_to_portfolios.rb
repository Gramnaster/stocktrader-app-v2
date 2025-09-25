class AddUniqueConstraintToPortfolios < ActiveRecord::Migration[8.0]
  def change
    # Add unique constraint to ensure only one portfolio entry per user-stock combination
    add_index :portfolios, [ :user_id, :stock_id ], unique: true, name: 'index_portfolios_on_user_id_and_stock_id_unique'
  end
end
