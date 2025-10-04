require "finnhub_ruby"
# Use robust FinnhubClient with key rotation
require "redis"

class UpdateDailyMarketCapJob < ApplicationJob
  queue_as :default

  # Get market cap and update stocks table
  def perform(*args)
    redis = Redis.new
    begin
      redis.set("update_daily_market_cap_job_running", true)
      Rails.logger.debug "Starting update daily market cap job..."

      Stock.find_each do |stock|
        begin
          FinnhubClient.try_request do |client|
            company_profile = client.company_profile2(symbol: stock.ticker)
            if company_profile && company_profile["marketCapitalization"]
              market_cap = company_profile["marketCapitalization"] * 1_000_000
              stock.update!(market_cap: market_cap)
              Rails.logger.debug "Successfully updated market cap for #{stock.ticker}: $#{(market_cap / 1_000_000_000).round(2)}B"
            else
              Rails.logger.debug "No market cap data available for #{stock.ticker}"
            end
          end
          sleep(1.1)

        rescue StandardError => e
          Rails.logger.debug "Error updating market cap for #{stock.ticker}: #{e.message}"
          next
        end
      end

      Rails.logger.debug "Market cap job completed!"
    ensure
      redis.del("update_daily_market_cap_job_running")
    end
  end
end
