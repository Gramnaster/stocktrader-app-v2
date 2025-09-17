class Country < ApplicationRecord
  has_many :users
  has_many :stocks

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
end
