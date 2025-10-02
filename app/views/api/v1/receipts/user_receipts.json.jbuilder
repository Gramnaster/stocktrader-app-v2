json.array! @receipts do |receipt|
  json.id receipt.id
  json.user_id receipt.user_id
  json.stock_id receipt.stock_id
  json.transaction_type receipt.transaction_type
  json.quantity receipt.quantity
  json.price_per_share receipt.price_per_share
  json.total_amount receipt.total_amount
  json.created_at receipt.created_at
  json.updated_at receipt.updated_at

  json.user do
    json.id receipt.user.id
    json.email receipt.user.email
    json.first_name receipt.user.first_name
    json.last_name receipt.user.last_name
  end

  if receipt.stock
    json.stock do
      json.id receipt.stock.id
      json.ticker receipt.stock.ticker
      json.company_name receipt.stock.name
      json.current_price receipt.stock.current_price
      json.currency receipt.stock.currency
      json.logo_url receipt.stock.logo_url
    end
  else
    json.stock nil
  end
end
