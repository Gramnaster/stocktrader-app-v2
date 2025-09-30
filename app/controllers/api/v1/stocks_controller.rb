class Api::V1::StocksController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  def index
    @stocks = Stock.all
  end

  def show
    @stock = Stock.find(params[:id])
  end
end
