# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

# Specifies the number of threads that each worker process will use.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 8)
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3001)

# Specifies the `environment` that Puma will run in.
# This is crucial for ensuring the correct Rails environment is loaded.
environment ENV.fetch("RAILS_ENV") { "development" }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Specify the PID file.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Preload the application before starting the workers for better performance.
preload_app!

# This block runs in each worker process after it has been booted.
# It is the safe place to interact with the loaded Rails application.
on_worker_boot do
  # Establish the database connection for Active Record.
  ActiveRecord::Base.establish_connection

  # Safely check the environment and load the Solid Queue plugin.
  if ENV["SOLID_QUEUE_IN_PUMA"] || Rails.env.development?
    # This requires `gem "puma-plugin-solid_queue"` in your Gemfile
    Puma.plugin :solid_queue
  end

  # Safely schedule your background jobs.
  # Note: This will run every time a worker starts.
  # Consider if this is the desired behavior or if it should be a one-off task.
  Rails.application.config.after_initialize do
    UpdateDailyClosingPricesJob.perform_later
    # UpdateDailyMarketCapJob.perform_now
  end
end
