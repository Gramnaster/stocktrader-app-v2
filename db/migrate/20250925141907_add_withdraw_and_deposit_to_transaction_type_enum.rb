class AddWithdrawAndDepositToTransactionTypeEnum < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      ALTER TYPE transaction_type ADD VALUE IF NOT EXISTS 'withdraw';
      ALTER TYPE transaction_type ADD VALUE IF NOT EXISTS 'deposit';
    SQL
  end

  def down
  end
end
