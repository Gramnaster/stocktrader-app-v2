class Receipt < ApplicationRecord
  belongs_to :user
  belongs_to :stock

  enum :transaction_type, { buy: "buy", sell: "sell", withdraw: "withdraw", deposit: "deposit" }

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_per_share, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
