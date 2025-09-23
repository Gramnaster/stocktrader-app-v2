class DropTransactionsTableAndEnum < ActiveRecord::Migration[8.0]
  def up
    drop_table :transactions, if_exists: true

    execute <<-SQL
      DO $$
      BEGIN
        IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transaction_type') THEN
          DROP TYPE transaction_type;
        END IF;
      END
      $$;
    SQL
  end

  def down
    execute <<-SQL
      CREATE TYPE IF NOT EXISTS transaction_type AS ENUM ('buy', 'sell');
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
end