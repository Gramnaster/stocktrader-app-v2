class Api::V1::UsersController < Api::V1::BaseController
  include AdminAuthorization
  before_action :require_admin, only: [ :index, :update_status ]
  before_action :set_user, only: [ :show, :update_status ]

  def index
    @users = User.all
    render json: @users.as_json(except: [ :password_digest, :jti ])
  end

  def show
    render json: @user.as_json(except: [ :password_digest, :jti ])
  end

  def update_status
    if @user.update(user_status: params[:user_status])
      render json: {
        message: "User status updated successfully",
        user: @user.as_json(only: [ :id, :email, :first_name, :last_name, :user_status ])
      }
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:user_status)
  end
end
