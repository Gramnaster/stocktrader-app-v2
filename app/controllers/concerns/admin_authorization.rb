module AdminAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def require_admin
    unless current_user&.admin?
      render json: { error: "Access denied. Admin privileges required." }, status: :forbidden
    end
  end

  def require_approved_user
    unless current_user&.approved?
      render json: { error: "Access denied. Account must be approved to perform this action." }, status: :forbidden
    end
  end
end
