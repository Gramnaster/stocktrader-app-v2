class CreateStockReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.boolean :vote, null: false

      t.timestamps
    end

    add_index :stock_reviews, [ :user_id, :stock_id ], unique: true
  end
end
