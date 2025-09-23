class Stock < ApplicationRecord
  belongs_to :country

  has_many :portfolios, dependent: :destroy
  has_many :users, through: :portfolios
  has_many :historical_prices, dependent: :destroy
  # has_many :transactions, dependent: :destroy
  has_many :receipts, dependent: :destroy

  validates :ticker, presence: true, uniqueness: true
  validates :name, presence: true
end
