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
    countries_data = nil
    FinnhubClient.try_request do |client|
      countries_data = client.country
    end

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

puts "Creating default admin user..."

# Create default admin user (after countries are seeded)
admin_email = ENV['ADMIN_EMAIL']
admin_password = ENV['ADMIN_PASSWORD']

# Get the first country (or default to US)
default_country = Country.find_by(code: 'US') || Country.first

if default_country.nil?
  puts "Error: No countries found in database. Please check Finnhub API connection."
  exit 1
end

admin_user = User.find_or_create_by!(email: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.first_name = 'System'
  user.last_name = 'Administrator'
  user.date_of_birth = 30.years.ago
  user.mobile_no = '1234567890'
  user.address_line_01 = '123 Admin Street'
  user.city = 'Admin City'
  user.zip_code = '12345'
  user.country = default_country  # Use the Country object, not an integer
  user.user_role = 'admin'
  user.user_status = 'approved'
  user.confirmed_at = Time.current  # Skip email confirmation
  puts "  -> Created admin user: #{user.email} in #{default_country.name}"
end

if admin_user.persisted? && !admin_user.changed?
  puts "  -> Admin user already exists: #{admin_user.email}"
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
    NASDAQ_100_TICKERS.each do |ticker|
      if Stock.exists?(ticker: ticker)
        puts "Skipping #{ticker}, it already exists in the database."
        next
      end

      profile = nil
      FinnhubClient.try_request do |client|
        profile = client.company_profile2(symbol: ticker)
      end

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
