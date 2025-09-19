class Api::V1::HistoricalPricesController < ApplicationController
  def index
    @historical_prices = HistoricalPrice.all
  end

  def show
    @historical_price = HistoricalPrice.find(params[:id])
  end
end
