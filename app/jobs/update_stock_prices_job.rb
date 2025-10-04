require "finnhub_ruby"
# Use robust FinnhubClient with key rotation
require "redis"

class UpdateStockPricesJob < ApplicationJob
  queue_as :default

  def perform
    redis = Redis.new
    if redis.get("update_daily_closing_prices_job_running")
      Rails.logger.debug "Skipping UpdateStockPricesJob because UpdateDailyClosingPricesJob is running"
      return
    end

    Rails.logger.debug "Starting stock price update job..."

    Stock.find_each do |stock|
      begin
        # `Rails.cache.fetch` will first try to find a result in Redis with the given key.
        quote = Rails.cache.fetch("stock-quote-#{stock.ticker}", expires_in: 60.seconds) do
          Rails.logger.debug "CACHE MISS: Fetching fresh quote for #{stock.ticker} from Finnhub API."
          result = nil
          FinnhubClient.try_request do |client|
            result = client.quote(stock.ticker)
          end
          sleep(1.2) # Stay under the 60 calls/minute rate limit.
          result
        end
        # If there was a "cache hit", the code above instantly returns the cached value
        # from Redis, and the block is completely skipped.

        # Now, update the database with the (potentially cached) quote data.
        stock.update!(
          current_price:        quote["c"],
          daily_change:         quote["d"],
          percent_daily_change: quote["dp"]
        )
      rescue StandardError => e
        Rails.logger.error "Finnhub API error for #{stock.ticker}: #{e.message}"
        next
      end
    end
    Rails.logger.debug "Finished stock price update job."
  end
end
