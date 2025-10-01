# frozen_string_literal: true

class Api::V1::Users::ConfirmationsController < Devise::ConfirmationsController
  respond_to :json

  # Ensure we don't require authentication for confirmation
  skip_before_action :authenticate_user!, raise: false

  # Set the correct Devise mapping
  before_action :set_devise_mapping

  # Override show to handle confirmation tokens properly
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed) if is_flashing_format?
      render json: {
        status: { code: 200, message: "Email successfully confirmed." },
        data: { id: resource.id, email: resource.email, confirmed: true }
      }, status: :ok
    else
      render json: {
        status: { message: "Invalid confirmation token." },
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  private

  def set_devise_mapping
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
