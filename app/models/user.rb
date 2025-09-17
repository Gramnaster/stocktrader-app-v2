class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :timeoutable

  enum :user_status, { pending: "pending", approved: "approved", rejected: "rejected" }
  enum :user_role, { trader: "trader", admin: "admin" }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true

  validates :mobile_no, presence: true, uniqueness: true
  validates :zip_code, presence: true

  belongs_to :country
  validates :country, presence: true

  has_one :wallet, dependent: :destroy
  validates :wallet, presence: true

  has_many :portfolios, dependent: :destroy
  has_many :stocks, through: :portfolios
  has_many :transactions, dependent: :destroy
  has_many :stock_reviews, dependent: :destroy
end
