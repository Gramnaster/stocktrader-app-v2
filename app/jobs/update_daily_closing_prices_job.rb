require "finnhub_ruby"
require "redis"

class UpdateDailyClosingPricesJob < ApplicationJob
  queue_as :default

  # Get closing price of today, set price record, update historical_data table
  def perform(*args)
    redis = Redis.new
    begin
      redis.set("update_daily_closing_prices_job_running", true)
      puts "Starting update daily closing prices job..."
      target_date = Date.yesterday

        Stock.find_each do |stock|
          FinnhubClient.try_request do |client|
            quote = client.quote(stock.ticker)
            price_record = stock.historical_prices.find_or_initialize_by(date: target_date)
            price_record.update!(previous_close: quote["pc"])
            puts "Successfully saved closing price for #{stock.ticker} on #{target_date}"
          end
          sleep(0.5)
        end
    ensure
      redis.del("update_daily_closing_prices_job_running")
    end
  end
end
