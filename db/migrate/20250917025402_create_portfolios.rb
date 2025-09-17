class CreatePortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolios, primary_key: [ :user_id, :stock_id ], id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.decimal :quantity, precision: 15, scale: 5, null: false, default: 0

      t.timestamps
    end
  end
end
