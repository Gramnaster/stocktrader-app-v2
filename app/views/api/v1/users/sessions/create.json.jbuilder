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

  # Portfolios information
  json.portfolios resource.portfolios.includes(:stock) do |portfolio|
    json.user_id portfolio.user_id
    json.stock_id portfolio.stock_id
    json.quantity portfolio.quantity
    json.created_at portfolio.created_at
    json.updated_at portfolio.updated_at

    # Stock information for each portfolio
    json.stock do
      json.id portfolio.stock.id
      json.ticker portfolio.stock.ticker
      json.company_name portfolio.stock.name
      json.current_price portfolio.stock.current_price
      json.currency portfolio.stock.currency if portfolio.stock.respond_to?(:currency)
      json.market_cap portfolio.stock.market_cap if portfolio.stock.respond_to?(:market_cap)
      json.sector portfolio.stock.sector if portfolio.stock.respond_to?(:sector)
      json.logo_url portfolio.stock.logo_url if portfolio.stock.respond_to?(:logo_url)
    end

    # Calculate portfolio value for this stock
    json.portfolio_value (portfolio.quantity * portfolio.stock.current_price).round(2)
  end

  # Portfolio summary
  total_portfolio_value = resource.portfolios.includes(:stock).sum { |p| p.quantity * p.stock.current_price }
  json.portfolio_summary do
    json.total_stocks resource.portfolios.count
    json.total_portfolio_value total_portfolio_value.round(2)
    json.total_shares resource.portfolios.sum(:quantity)
  end

  # JWT token identifier
  json.jti resource.jti
end
