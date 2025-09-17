# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

NASDAQ_100_TICKERS = [
  'AAPL', 'MSFT', 'AMZN', 'NVDA', 'GOOGL', 'GOOG', 'TSLA', 'META', 'AVGO', 'PEP',
  'COST', 'ADBE', 'CSCO', 'TMUS', 'NFLX', 'AMD', 'CMCSA', 'INTC', 'TXN', 'QCOM',
  'HON', 'AMGN', 'INTU', 'SBUX', 'GILD', 'MDLZ', 'ISRG', 'ADP', 'PYPL', 'BKNG',
  'ADI', 'REGN', 'VRTX', 'FISV', 'LRCX', 'MU', 'CSX', 'ATVI', 'AMAT', 'MNST',
  'KDP', 'PANW', 'ORLY', 'MAR', 'CTAS', 'AEP', 'FTNT', 'CDNS', 'CHTR', 'SNPS',
  'KLAC', 'EXC', 'PAYX', 'PCAR', 'DXCM', 'MCHP', 'ROP', 'XEL', 'CTSH', 'ADSK',
  'EA', 'BIIB', 'LULU', 'WBA', 'KHC', 'MELI', 'IDXX', 'ROST', 'EBAY', 'WBD',
  'FAST', 'CRWD', 'ODFL', 'CSGP', 'CPRT', 'DDOG', 'VRSK', 'CEG', 'GEHC', 'ANSS',
  'SIRI', 'DLTR', 'MRVL', 'TEAM', 'AZN', 'BKR', 'ILMN', 'MRNA', 'ALGN', 'ZS',
  'ON', 'EXPD', 'TTD', 'PCG', 'DASH', 'SGEN', 'ENPH', 'GEN', 'FANG', 'ZBRA'
]

puts "Seeding stocks..."

# Create a new instance of the Finnhub API client.
# This will work because your initializer has already run.
client = FinnhubRuby::DefaultApi.new

# --- Pre-fetch the USA Country record ---
# This is more efficient than finding it inside the loop every time.
# This assumes you have already seeded your countries table.
usa = Country.find_by(code: 'US')
unless usa
  puts "Error: Could not find Country with code 'US'. Please seed countries first."
  exit # Stop the seed process if the dependency is not met.
end

NASDAQ_100_TICKERS.each do |ticker|
  # --- Idempotency Check: Skip if the stock already exists ---
  if Stock.exists?(ticker: ticker)
    puts "Skipping #{ticker}, it already exists in the database."
    next
  end

  begin
    # --- Step 1: Call the /company-profile2 endpoint for static data ---
    profile = client.company_profile2(symbol: ticker)

    # The free Finnhub API can sometimes return a nil profile. We must check for this.
    if profile.nil? || profile.name.blank?
      puts "Warning: Could not fetch a valid profile for #{ticker}. Skipping."
      next
    end

    # --- Step 2: Create the stock record in your database ---
    # We are intentionally leaving the price columns (current_price, etc.) nil.
    # The background job will populate these later.
    Stock.create!(
      ticker:        profile.ticker,
      name:          profile.name,
      logo_url:      profile.logo,
      web_url:       profile.weburl,
      exchange:      profile.exchange,
      country:       usa # Associate the stock with the pre-fetched USA country record
    )

    puts "Successfully seeded #{profile.name} (#{ticker})"

    # --- IMPORTANT: Add a small delay to respect the free API's rate limit ---
    # The free tier is 60 calls/minute. A 1.1-second delay keeps you safely under.
    sleep(1.1)

  rescue FinnhubRuby::ApiError => e
    puts "Error seeding #{ticker}: #{e.message}. Skipping."
    next
  end
end

puts "Finished seeding stocks."
