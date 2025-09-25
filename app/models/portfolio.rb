class Portfolio < ApplicationRecord
  self.primary_key = [ :user_id, :stock_id ]

  belongs_to :user
  belongs_to :stock

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :stock_id, message: "can only have one portfolio entry per stock" }

  def self.find_or_create_for_user_and_stock(user, stock)
    find_or_create_by(user: user, stock: stock) do |portfolio|
      portfolio.quantity = 0
    end
  end

  def add_shares(quantity)
    self.quantity += quantity
    save!
  end

  def remove_shares(quantity)
    if self.quantity < quantity
      raise StandardError, "Cannot sell #{quantity} shares, only #{self.quantity} available"
    end

    self.quantity -= quantity

    if self.quantity == 0
      destroy!
      true
    else
      save!
      false
    end
  end

  def current_market_value
    quantity * stock.current_price
  end
end
