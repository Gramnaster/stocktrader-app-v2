# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'finnhub_ruby'

puts "Seeding country data from Finnhub..."

ActiveRecord::Base.transaction do
  begin
    client = FinnhubRuby::DefaultApi.new

    puts "Fetching countries list"
    countries_data = client.country

    puts "Populating countries table"
    countries_data.each do |country_data|
      country_code = country_data['code2']
      Country.find_or_create_by!(code: country_code) do |country|
        country.name = country_data['country']
        puts "  -> Created country: #{country.name} (#{country.code})"
      end
    end
    puts "Countries table populated successfully."

  rescue StandardError => e
    if e.class.to_s == 'FinnhubRuby::ApiError'
      puts "Finnhub API Error: #{e.message}. Rolling back country creations."
    else
      puts "Failed to fetch country data. Aborting seed. Error: #{e.message}"
    end
    raise ActiveRecord::Rollback

  rescue => e
    puts "Error: #{e.message}"
    raise ActiveRecord::Rollback
  end
end

# Seeding stocks

NASDAQ_100_TICKERS = [
  'AAPL', 'ABNB', 'ADBE', 'ADI', 'ADP', 'ADSK', 'AEP', 'AMAT', 'AMD', 'AMGN',
  'AMZN', 'APP', 'ARM', 'ASML', 'AVGO', 'AXON', 'AZN', 'BIIB', 'BKNG', 'BKR',
  'CCEP', 'CDNS', 'CDW', 'CEG', 'CHTR', 'CMCSA', 'COST', 'CPRT', 'CRWD', 'CSCO',
  'CSGP', 'CSX', 'CTAS', 'CTSH', 'DASH', 'DDOG', 'DXCM', 'EA', 'EXC', 'FANG',
  'FAST', 'FTNT', 'GEHC', 'GFS', 'GILD', 'GOOG', 'GOOGL', 'HON', 'IDXX', 'INTC',
  'INTU', 'ISRG', 'KDP', 'KHC', 'KLAC', 'LIN', 'LRCX', 'LULU', 'MAR', 'MCHP',
  'MDLZ', 'MELI', 'META', 'MNST', 'MRVL', 'MSFT', 'MSTR', 'MU', 'NFLX', 'NVDA',
  'NXPI', 'ODFL', 'ON', 'ORLY', 'PANW', 'PAYX', 'PCAR', 'PDD', 'PEP', 'PLTR',
  'PYPL', 'QCOM', 'REGN', 'ROP', 'ROST', 'SBUX', 'SHOP', 'SNPS', 'TEAM', 'TMUS',
  'TRI', 'TSLA', 'TTD', 'TTWO', 'TXN', 'VRSK', 'VRTX', 'WBD', 'WDAY', 'XEL', 'ZS'
]

puts "Seeding stocks..."

# Wrap the entire stock seeding process in a transaction for safety.
ActiveRecord::Base.transaction do
  begin
    client = FinnhubRuby::DefaultApi.new

    NASDAQ_100_TICKERS.each do |ticker|
      if Stock.exists?(ticker: ticker)
        puts "Skipping #{ticker}, it already exists in the database."
        next
      end

      profile = client.company_profile2(symbol: ticker)

      if profile.nil? || profile['name'].blank?
        puts "Warning: Could not fetch a valid profile for #{ticker}. Skipping."
        next
      end

      stock_country = Country.find_by(code: profile['country'])
      if stock_country.nil?
        # If stock is not in a country list, skip it.
        puts "Warning: Country '#{profile['country']}' for stock #{ticker} not found in the database. Skipping."
        next
      end

      Stock.create!(
        name:          profile['name'],
        ticker:        ticker,
        country:       stock_country,
        exchange:      profile['exchange'],
        currency:      profile['currency'],
        web_url:       profile['weburl'],
        logo_url:      profile['logo']
      )

      puts "Successfully seeded #{profile['name']} (#{ticker})"
      sleep(1.1)
    end

    puts "Finished seeding stocks successfully."

  rescue StandardError => e
    if e.class.to_s == 'FinnhubRuby::ApiError'
      puts "Finnhub API Error: #{e.message}. Rolling back stock creations."
    else
      puts "Error: #{e.message}. Rolling back all stock creations."
    end
    raise ActiveRecord::Rollback
  rescue => e
    puts "Error: #{e.message}. Rolling back all stock creations."
    raise ActiveRecord::Rollback
  end
end
