class Api::V1::WalletsController < Api::V1::BaseController
  before_action :authenticate_user!
  def index
    @wallets = Wallet.all
  end

  def show
    @wallet = Wallet.find(params[:id])
  end
end
