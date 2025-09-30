json.array! @portfolios do |portfolio|
  json.id portfolio.id
  json.user_id portfolio.user_id
  json.stock_id portfolio.stock_id
  json.quantity portfolio.quantity
  json.current_market_value portfolio.current_market_value
  json.created_at portfolio.created_at
  json.updated_at portfolio.updated_at

  # User details (for admin view)
  json.user do
    json.id portfolio.user.id
    json.email portfolio.user.email
    json.first_name portfolio.user.first_name
    json.last_name portfolio.user.last_name
    json.user_status portfolio.user.user_status
  end

  # Stock details
  json.stock do
    json.id portfolio.stock.id
    json.ticker portfolio.stock.ticker
    json.company_name portfolio.stock.name
    json.current_price portfolio.stock.current_price
    json.currency portfolio.stock.currency
  end
end
