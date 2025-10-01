json.status do
  json.code 200
  json.message "Logged in successfully."
end

json.data do
  # Basic identity
  json.id resource.id
  json.email resource.email
  json.first_name resource.first_name
  json.middle_name resource.middle_name
  json.last_name resource.last_name
  json.date_of_birth resource.date_of_birth
  json.mobile_no resource.mobile_no

  # Address information
  json.address_line_01 resource.address_line_01
  json.address_line_02 resource.address_line_02
  json.city resource.city
  json.zip_code resource.zip_code

  # Country information
  json.country do
    json.id resource.country.id
    json.name resource.country.name
    json.code resource.country.code if resource.country.respond_to?(:code)
  end

  # User status and role
  json.user_status resource.user_status
  json.user_role resource.user_role

  # Email confirmation status
  json.confirmed_at resource.confirmed_at
  json.email_confirmed resource.confirmed_at.present?

  # Wallet information
  if resource.wallet.present?
    json.wallet do
      json.id resource.wallet.id
      json.balance resource.wallet.balance
    end
  end

  # Account timestamps
  json.created_at resource.created_at
  json.updated_at resource.updated_at
  json.remember_created_at resource.remember_created_at

  # JWT token identifier
  json.jti resource.jti
end
