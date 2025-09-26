class Api::V1::ReceiptsController < ApplicationController
  def index
  end

  def show
  end

  private

  def set_receipts
    @receipt = Receipt.find(params[:id])
  end

  def receipts_params
  end
end
