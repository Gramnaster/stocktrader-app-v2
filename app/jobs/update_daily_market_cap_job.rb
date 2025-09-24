require "finnhub_ruby"
require "redis"

class UpdateDailyMarketCapJob < ApplicationJob
  queue_as :default

  # Get market cap and update stocks table
  def perform(*args)
    redis = Redis.new
    begin
      redis.set("update_daily_market_cap_job_running", true)
      puts "Starting update daily market cap job..."
      client = FinnhubRuby::DefaultApi.new

      Stock.find_each do |stock|
        begin
          company_profile = client.company_profile2(symbol: stock.ticker)

          if company_profile && company_profile["marketCapitalization"]
            market_cap = company_profile["marketCapitalization"] * 1_000_000
            stock.update!(market_cap: market_cap)
            puts "Successfully updated market cap for #{stock.ticker}: $#{(market_cap / 1_000_000_000).round(2)}B"
          else
            puts "No market cap data available for #{stock.ticker}"
          end

          sleep(1.1)

        rescue StandardError => e
          puts "Error updating market cap for #{stock.ticker}: #{e.message}"
          next
        end
      end

      puts "Market cap job completed!"
    ensure
      redis.del("update_daily_market_cap_job_running")
    end
  end
end
