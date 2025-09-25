class Receipt < ApplicationRecord
  belongs_to :user
  belongs_to :stock

  enum :transaction_type, { buy: "buy", sell: "sell" }

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_per_share, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_create :execute_transaction

  def wallet
    user.wallet
  end

  def buy(quantity, stock_symbol)
    stock_data = Stock.find_by(ticker: stock_symbol)
    return nil unless stock_data

    current_price = stock_data.current_price
    total_cost = quantity * current_price

    if wallet.balance < total_cost
      raise StandardError, "Insufficient funds: balance is #{wallet.balance}, need #{total_cost}"
    end

    portfolio = Portfolio.find_or_create_for_user_and_stock(user, stock_data)

    portfolio.add_shares(quantity)

    new_balance = wallet.withdraw(total_cost)
    wallet.update!(balance: new_balance)

    {
      portfolio_id: [ portfolio.user_id, portfolio.stock_id ],
      price_per_share: current_price,
      total_cost: total_cost,
      new_balance: new_balance
    }
  end

  def sell(quantity, stock_symbol)
    stock_data = Stock.find_by(ticker: stock_symbol)
    return nil unless stock_data

    current_price = stock_data.current_price

    portfolio = Portfolio.find_by(user: user, stock: stock_data)

    if !portfolio || portfolio.quantity < quantity
      raise StandardError, "Insufficient shares: you have #{portfolio&.quantity || 0}, trying to sell #{quantity}"
    end

    total_proceeds = quantity * current_price

    portfolio_destroyed = portfolio.remove_shares(quantity)

    new_balance = wallet.deposit(total_proceeds)
    wallet.update!(balance: new_balance)

    {
      portfolio_id: portfolio_destroyed ? nil : [ portfolio.user_id, portfolio.stock_id ],
      price_per_share: current_price,
      total_proceeds: total_proceeds,
      new_balance: new_balance,
      portfolio_destroyed: portfolio_destroyed
    }
  end

  private

  def execute_transaction
    case transaction_type
    when "buy"
      result = buy(quantity, stock.ticker)
      if result
        update_columns(
          price_per_share: result[:price_per_share],
          total_amount: result[:total_cost]
        )
      end
    when "sell"
      result = sell(quantity, stock.ticker)
      if result
        update_columns(
          price_per_share: result[:price_per_share],
          total_amount: result[:total_proceeds]
        )
      end
    end
  rescue StandardError => e
    destroy!
    raise e
  end
end
