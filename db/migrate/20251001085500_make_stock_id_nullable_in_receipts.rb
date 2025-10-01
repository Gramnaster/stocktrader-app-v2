class MakeStockIdNullableInReceipts < ActiveRecord::Migration[8.0]
  def up
    # Make stock_id nullable for deposit/withdraw transactions
    change_column_null :receipts, :stock_id, true
  end

  def down
    # Revert to not null (only if no deposit/withdraw records exist)
    change_column_null :receipts, :stock_id, false
  end
end
