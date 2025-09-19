class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :timeoutable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  enum :user_status, { pending: "pending", approved: "approved", rejected: "rejected" }
  enum :user_role, { trader: "trader", admin: "admin" }

  # Automatically create a wallet when a new user is created
  after_create :create_user_wallet

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true

  validates :mobile_no, presence: true, uniqueness: true
  validates :zip_code, presence: true

  belongs_to :country
  validates :country, presence: true

  has_one :wallet, dependent: :destroy

  has_many :portfolios, dependent: :destroy
  has_many :stocks, through: :portfolios
  has_many :transactions, dependent: :destroy
  has_many :stock_reviews, dependent: :destroy

  private

  def create_user_wallet
    Wallet.create!(
      user: self,
      balance: 0.0  # Starting balance of $0
    )
  end
end
