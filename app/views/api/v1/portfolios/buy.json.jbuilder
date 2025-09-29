json.message "Shares bought successfully"
json.receipt do
  json.id @receipt.id
  json.quantity @receipt.quantity
  json.price_per_share @receipt.price_per_share
  json.total_amount @receipt.total_amount
  json.transaction_type @receipt.transaction_type
  json.created_at @receipt.created_at

  # Stock details
  json.stock do
    json.id @receipt.stock.id
    json.ticker @receipt.stock.ticker
    json.company_name @receipt.stock.company_name
  end

  # User's updated wallet balance
  json.wallet_balance @receipt.user.wallet.balance
end
