json.message "Deposit successful"
json.receipt do
  json.id @receipt.id
  json.amount @receipt.total_amount
  json.transaction_type @receipt.transaction_type
  json.created_at @receipt.created_at

  # User's updated wallet balance
  json.wallet_balance @receipt.user.wallet.balance
end
