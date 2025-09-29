class Api::V1::ReceiptsController < Api::V1::BaseController
  include AdminAuthorization
  before_action :require_admin, only: [ :index ]
  before_action :set_receipt, only: [ :show ]

  def index
    @receipts = Receipt.all.includes(:user, :stock)
    render json: @receipts.as_json(
      include: {
        user: { only: [ :id, :email, :first_name, :last_name ] },
        stock: { only: [ :id, :ticker, :company_name ] }
      }
    )
  end

  def show
    # Users can only see their own receipts, admins can see all
    unless current_user.admin? || @receipt.user == current_user
      return render json: { error: "Access denied" }, status: :forbidden
    end

    render json: @receipt.as_json(
      include: {
        user: { only: [ :id, :email, :first_name, :last_name ] },
        stock: { only: [ :id, :ticker, :company_name ] }
      }
    )
  end

  private

  def set_receipt
    @receipt = Receipt.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Receipt not found" }, status: :not_found
  end
end
