class Api::V1::ReceiptsController < Api::V1::BaseController
  include AdminAuthorization
  before_action :require_admin, only: [ :index ]
  before_action :set_receipt, only: [ :show ]

  def index
    @receipts = Receipt.all.includes(:user, :stock)
  end

  def show
    # Users can only see their own receipts, admins can see all
    unless current_user.admin? || @receipt.user == current_user
      render json: { error: "Access denied" }, status: :forbidden
    end
  end

  def my_receipts
    @receipts = current_user.receipts.includes(:stock).order(created_at: :desc)
  end

  # GET /api/v1/users/:id/receipts
  def user_receipts
    user = User.find_by(id: params[:id])
    unless user
      render json: { error: "User not found" }, status: :not_found and return
    end
    # Only allow admin or the user themselves
    unless current_user.admin? || current_user.id == user.id
      render json: { error: "Access denied" }, status: :forbidden and return
    end
    @receipts = user.receipts.includes(:stock).order(created_at: :desc)
    render :user_receipts
  end

  private

  def set_receipt
    @receipt = Receipt.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Receipt not found" }, status: :not_found
  end
end
