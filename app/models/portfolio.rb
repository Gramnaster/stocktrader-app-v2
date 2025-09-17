class Portfolio < ApplicationRecord
  belongs_to :user
  belongs_to :stock

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
