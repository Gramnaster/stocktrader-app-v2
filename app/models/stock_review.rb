class StockReview < ApplicationRecord
  belongs_to :user
  belongs_to :stock

  validates :vote, presence: true, inclusion: { in: [ true, false ] }
end
