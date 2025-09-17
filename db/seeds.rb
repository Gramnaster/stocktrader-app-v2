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

  rescue FinnhubRuby::ApiError => e
    puts "Failed to fetch country data. Aborting seed. Error: #{e.message}"
    raise ActiveRecord::Rollback

  rescue => e
    puts "Error: #{e.message}"
    raise ActiveRecord::Rollback
  end
end
