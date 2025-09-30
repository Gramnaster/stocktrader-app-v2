json.array! @historical_prices do |historical_price|
  json.id historical_price.id
  json.stock_id historical_price.stock.id
  json.stock_name historical_price.stock.ticker
  json.date           historical_price.date
  json.previous_close historical_price.previous_close
end
