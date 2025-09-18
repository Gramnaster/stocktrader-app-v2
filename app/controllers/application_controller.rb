class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # This method tells Devise which custom parameters to allow for sign_up and account_update.
  def configure_permitted_parameters
    # For the :sign_up action (POST /api/v1/signup)
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :middle_name, :last_name, :date_of_birth, :mobile_no,
      :address_line_01, :address_line_02, :city, :zip_code, :country_id
    ])

    # You can also permit parameters for updating an account (:account_update)
    # devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, ...])
  end
end
