class Api::V1::UsersController < Api::V1::BaseController
  include AdminAuthorization
  before_action :require_admin, only: [ :index, :create, :update, :destroy, :update_status ]
  before_action :set_user, only: [ :show, :update, :destroy, :update_status ]

  def index
    @users = User.all.includes(:country, :wallet)
  end

  def show
  end

  def create
    @user = User.new(user_params)
    @user.password = params[:password] if params[:password].present?
    @user.password_confirmation = params[:password_confirmation] if params[:password_confirmation].present?

    # Auto-confirm admin-created users
    @user.confirmed_at = Time.current

    if @user.save
      render :create, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    # Handle password updates separately
    if params[:password].present?
      if @user.update(user_params.merge(
        password: params[:password],
        password_confirmation: params[:password_confirmation]
      ))
        render :update
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      if @user.update(user_params)
        render :update
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if @user.destroy
      render json: { message: "User deleted successfully" }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_status
    if @user.update(user_status: params[:user_status])
      render :update_status
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
    params.require(:user).permit(
      :email, :first_name, :middle_name, :last_name, :date_of_birth,
      :mobile_no, :address_line_01, :address_line_02, :city, :zip_code,
      :country_id, :user_role, :user_status
    )
  end
end
