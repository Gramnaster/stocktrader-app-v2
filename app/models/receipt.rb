class Receipt < ApplicationRecord
  belongs_to :user
  belongs_to :stock
  belongs_to :wallet

  enum :transaction_type, { buy: "buy", sell: "sell", withdraw: "withdraw", deposit: "deposit" }

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_per_share, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def buy(quantity, stock_symbol)
    id_price_array = self.wallet.update_portfolio(portfolio_id, quantity, stock_symbol)
    sell_price = sell_price_destroyed_array[0]
    new_balance = self.wallet.deposit(sell_price)

    return sell_price_destroyed_array << new_balance
  end
end
