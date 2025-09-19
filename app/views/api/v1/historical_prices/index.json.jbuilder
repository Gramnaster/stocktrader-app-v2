json.array! @historical_prices do |historical_price|
  json.id             historical_price.id
  json.stock          historical_price.stock
  json.date           historical_price.date
  json.previous_close historical_price.previous_close
end
