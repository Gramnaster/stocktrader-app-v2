json.array! @receipts do |receipt|
  json.user_id            @receipt.user_id
  json.stock_id           @receipt.stock_id
  json.transaction_type   @receipt.transaction_type
  json.quantity           @receipt.quantity
  json.price_per_share    @receipt.price_per_share
  json.total_amount       @receipt.total_amount
  json.created_at         @receipt.created_at
end
