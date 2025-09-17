class HistoricalPrice < ApplicationRecord
  belongs_to :stock

  validates :date, presence: true
  validates :previous_close, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
