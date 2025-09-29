class Api::V1::PortfoliosController < Api::V1::BaseController
  include AdminAuthorization
  before_action :require_admin, only: [ :index ]
  before_action :require_approved_user, only: [ :buy, :sell ]

  def index
    @portfolios = Portfolio.all.includes(:user, :stock)
    render json: @portfolios.as_json(
      include: {
        user: { only: [ :id, :email, :first_name, :last_name ] },
        stock: { only: [ :id, :ticker, :company_name, :current_price ] }
      },
      methods: [ :current_market_value ]
    )
  end

  def my_portfolios
    @portfolios = current_user.portfolios.includes(:stock)
    render json: @portfolios.as_json(
      include: {
        stock: { only: [ :id, :ticker, :company_name, :current_price ] }
      },
      methods: [ :current_market_value ]
    )
  end

  def show
    portfolio = Portfolio.find_by(user_id: current_user.id, stock_id: params[:stock_id])
    if portfolio
      render json: {
        stock: portfolio.stock.ticker,
        quantity: portfolio.quantity,
        market_value: portfolio.current_market_value
      }
    else
      render json: { error: "Portfolio not found" }, status: :not_found
    end
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
