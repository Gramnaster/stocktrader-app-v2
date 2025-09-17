# json.extract! @stock, :id, :name, :ticker, :exchange, :country, :web_url, :logo_url, :current_price, :daily_change, :percent_daily_change
json.id @stock.id
json.name @stock.name
json.ticker @stock.ticker
json.exchange @stock.exchange
json.country @stock.country
json.web_url @stock.web_url
json.logo_url @stock.logo_url
json.current_price @stock.current_price
json.daily_change @stock.daily_change
json.percent_daily_change @stock.percent_daily_change
