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
      render json: { error: "Access denied. You can only view your own portfolios." }, status: :forbidden
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Portfolio not found" }, status: :not_found
  end

  def buy
    stock = Stock.find_by(ticker: params[:ticker])
    return render json: { error: "Stock not found" }, status: :not_found unless stock

    portfolio = Portfolio.find_or_create_for_user_and_stock(current_user, stock)
    portfolio.add_shares(params[:quantity].to_i)
    render json: { message: "Shares bought", quantity: portfolio.quantity }
  end

  def sell
    stock = Stock.find_by(ticker: params[:ticker])
    return render json: { error: "Stock not found" }, status: :not_found unless stock

    portfolio = Portfolio.find_by(user: current_user, stock: stock)
    return render json: { error: "Portfolio not found" }, status: :not_found unless portfolio

    begin
      destroyed = portfolio.remove_shares(params[:quantity].to_i)
      msg = destroyed ? "All shares sold, portfolio entry deleted" : "Shares sold"
      render json: { message: msg }
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
