class CreateTransactions < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TYPE transaction_type AS ENUM ('buy', 'sell');
    SQL

    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true

      t.column :transaction_type, :transaction_type, null: false

      t.decimal :quantity, precision: 15, scale: 5, null: false
      t.decimal :price_per_share, precision: 15, scale: 2, null: false
      t.decimal :total_amount, precision: 15, scale: 2, null: false

      t.timestamps
    end
  end

  def down
    drop_table :transaction

    execute <<-SQL
      DROP TYPE transaction_type
    SQL
  end
end
