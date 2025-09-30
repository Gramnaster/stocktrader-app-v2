class Api::V1::PortfoliosController < Api::V1::BaseController
  include AdminAuthorization
  before_action :require_admin, only: [ :index ]
  before_action :require_approved_user, only: [ :buy, :sell ]

  def index
    @portfolios = Portfolio.all.includes(:user, :stock)
  end

  def my_portfolios
    @portfolios = current_user.portfolios.includes(:stock)
  end

  def show
    # Find portfolio by ID and ensure it belongs to current user (unless admin)
    @portfolio = Portfolio.find(params[:id])

    unless current_user.admin? || @portfolio.user == current_user
      render :access_denied, status: :forbidden
    end
  rescue ActiveRecord::RecordNotFound
    render :not_found, status: :not_found
  end

  def buy
    stock = Stock.find_by(ticker: params[:ticker])
    return render json: { error: "Stock not found" }, status: :not_found unless stock

    quantity = params[:quantity].to_i
    current_price = stock.current_price
    total_amount = quantity * current_price

    begin
      # Check wallet balance before creating receipt
      if current_user.wallet.balance < total_amount
        return render json: { error: "Insufficient funds: balance is #{current_user.wallet.balance}, need #{total_amount}" }, status: :unprocessable_entity
      end

      @receipt = Receipt.create!(
        user: current_user,
        stock: stock,
        transaction_type: "buy",
        quantity: quantity,
        price_per_share: current_price,
        total_amount: total_amount
      )

      render :buy
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def sell
    stock = Stock.find_by(ticker: params[:ticker])
    return render json: { error: "Stock not found" }, status: :not_found unless stock

    quantity = params[:quantity].to_i
    current_price = stock.current_price
    total_amount = quantity * current_price

    begin
      # Check portfolio shares before creating receipt
      portfolio = Portfolio.find_by(user: current_user, stock: stock)
      if portfolio.nil? || portfolio.quantity < quantity
        return render json: { error: "Insufficient shares: you have #{portfolio&.quantity || 0}, trying to sell #{quantity}" }, status: :unprocessable_entity
      end

      @receipt = Receipt.create!(
        user: current_user,
        stock: stock,
        transaction_type: "sell",
        quantity: quantity,
        price_per_share: current_price,
        total_amount: total_amount
      )

      render :sell
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
