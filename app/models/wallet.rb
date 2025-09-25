class Wallet < ApplicationRecord
  belongs_to :user
  has_many :receipts
  has_many :portfolio
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def withdraw(amount)
    self.balance = self.balance - amount
    return self.balance
  end

  def deposit(amount)
    self.balance = self.balance + amount
    return self.balance
  end

  def update_portfolio(quantity, stock_symbol)
    stock_data = Stock.find_by(ticker: stock_symbol)

    stock_price = stock_data.current_price

    portfolio = self.portfolios.create(quantity: stock_id: stock.id)

    price = quantity * stock_price

    return [portfolio.id, current_price]
  end

  def remove_portfolio(portfolio_id, quantity, stock_symbol)
    portfolio_data = Portfolio.find(portfolio_id)

    delete_this_portfolio = false

    if(portfolio_data.quantity > quantity)
      new_amount = portfolio_data.quantity - quantity
      portfolio_data.update!(quantity: new_quantity)
    elsif(portfolio_data.quantity == quantity)
      delete_this_portfolio = true
    else
      raise Walleterror, "Can't sell total shares"
    end

    stock_data = Stock.find_by ticker: stock_symbol
    stock_price = stock_data.current_price
    price = quantity * stock_price

    return [current_price, delete_this_portfolio]
  end

  def balance_is_negative
    if self.balance < 0
      return true
    else
      return false
    end
  end
end
