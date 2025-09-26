json.array! @portfolios do |portfolio|
  json.user_id portfolio.user_id
  json.stock_id portfolio.stock_id
  json.stock_ticker portfolio.stock.ticker
  json.quantity portfolio.quantity
  json.current_price portfolio.stock.current_price
  json.market_value portfolio.current_market_value
  json.created_at @portfolio.created_at
  json.updated_at @portfolio.updated_at
end
