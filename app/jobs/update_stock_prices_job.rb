require "finnhub_ruby"
require "redis"

class UpdateStockPricesJob < ApplicationJob
  queue_as :default

  def perform
    redis = Redis.new
    if redis.get("update_daily_closing_prices_job_running")
      p "Skipping UpdateStockPricesJob because UpdateDailyClosingPricesJob is running"
      return
    end

    puts "Starting stock price update job..."
    client = FinnhubRuby::DefaultApi.new

    Stock.find_each do |stock|
      begin
        # `Rails.cache.fetch` will first try to find a result in Redis with the given key.
        quote = Rails.cache.fetch("stock-quote-#{stock.ticker}", expires_in: 3.minutes) do
          # This block of code ONLY runs if there is a "cache miss"
          # (i.e., the key is not found in Redis or has expired).
          puts "CACHE MISS: Fetching fresh quote for #{stock.ticker} from Finnhub API."
          data = client.quote(stock.ticker)
          sleep(1.1) # Stay under the 60 calls/minute rate limit.
          data # Return the data to be cached.
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
    puts "Finished stock price update job."
  end
end
