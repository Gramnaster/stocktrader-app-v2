class Api::V1::WalletsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :require_approved_user, only: [ :deposit, :withdraw ]

  def index
    @wallets = Wallet.all
  end

  def show
    @wallet = Wallet.find(params[:id])
    @user = current_user
  end

  def deposit
    amount = params[:amount].to_f

    return render json: { error: "Amount must be greater than 0" }, status: :unprocessable_entity if amount <= 0
    return render json: { error: "Amount must be reasonable (max $1,000,000)" }, status: :unprocessable_entity if amount > 1_000_000

    begin
      @receipt = Receipt.create!(
        user: current_user,
        stock: nil,  # No stock for wallet transactions
        transaction_type: "deposit",
        quantity: 1,  # Set to 1 for wallet transactions
        price_per_share: amount,  # Use price_per_share field for amount
        total_amount: amount
      )

      render :deposit
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def withdraw
    amount = params[:amount].to_f

    return render json: { error: "Amount must be greater than 0" }, status: :unprocessable_entity if amount <= 0

    begin
      # Check wallet balance before creating receipt
      if current_user.wallet.balance < amount
        return render json: { error: "Insufficient funds: balance is #{current_user.wallet.balance}, need #{amount}" }, status: :unprocessable_entity
      end

      @receipt = Receipt.create!(
        user: current_user,
        stock: nil,  # No stock for wallet transactions
        transaction_type: "withdraw",
        quantity: 1,  # Set to 1 for wallet transactions
        price_per_share: amount,  # Use price_per_share field for amount
        total_amount: amount
      )

      render :withdraw
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
