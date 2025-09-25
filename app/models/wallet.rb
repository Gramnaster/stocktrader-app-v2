class Wallet < ApplicationRecord
  belongs_to :user
  has_many :portfolios, through: :user
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def withdraw(amount)
    self.balance = self.balance - amount
    self.balance
  end

  def deposit(amount)
    self.balance = self.balance + amount
    self.balance
  end

  def update_portfolio(quantity, stock_symbol)
    stock_data = Stock.find_by(ticker: stock_symbol)
    return nil unless stock_data

    stock_price = stock_data.current_price

    portfolio = Portfolio.find_or_create_for_user_and_stock(user, stock_data)
    portfolio.add_shares(quantity)

    total_price = quantity * stock_price

    [ [ portfolio.user_id, portfolio.stock_id ], total_price ]
  end

  def remove_portfolio(portfolio_id, quantity, stock_symbol)
    portfolio_data = Portfolio.find(portfolio_id)

    stock_data = Stock.find_by(ticker: stock_symbol)
    stock_price = stock_data.current_price
    price = quantity * stock_price

    delete_this_portfolio = portfolio_data.remove_shares(quantity)

    [ price, delete_this_portfolio ]
  end

  def balance_is_negative
    balance < 0
  end
end
