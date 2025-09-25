class Stock < ApplicationRecord
  belongs_to :country

  has_many :portfolios, dependent: :destroy
  has_many :users, through: :portfolios
  has_many :historical_prices, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :stock_reviews, dependent: :destroy

  validates :ticker, presence: true, uniqueness: true
  validates :name, presence: true
  validates :currency, presence: true
  validates :current_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :market_cap, numericality: { greater_than_or_equal_to: 0 }
end
