# json.extract! @country, :id, :code, :name
json.id @country.id
json.code @country.code
json.name @country.name
json.stocks @stocks do |stock|
  json.id stock.id
  json.ticker stock.ticker
  json.name stock.name
end
