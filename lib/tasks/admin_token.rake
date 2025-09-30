namespace :admin do
  desc "Create admin user and get JWT token for testing"
  task get_token: :environment do
    # Find or create an admin user
    admin = User.find_or_create_by(email: "admin@stocktrader.com") do |user|
      user.password = "admin123"
      user.password_confirmation = "admin123"
      user.first_name = "Admin"
      user.last_name = "User"
      user.date_of_birth = "1980-01-01"
      user.mobile_no = "9999999999"
      user.zip_code = "00000"
      user.user_role = "admin"
      user.user_status = "approved"
      user.confirmed_at = Time.current  # Auto-confirm

      # Find or create a country
      country = Country.first || Country.create!(code: "US", name: "United States")
      user.country = country
    end

    if admin.persisted?
      # Generate JWT token
      token = Warden::JWTAuth::UserEncoder.new.call(admin, :user, nil)

      puts "\n" + "="*60
      puts "🔑 ADMIN JWT TOKEN FOR TESTING"
      puts "="*60
      puts "Admin Email: #{admin.email}"
      puts "Admin Password: admin123"
      puts "Admin ID: #{admin.id}"
      puts "\nJWT Token:"
      puts token.first
      puts "\n" + "="*60
      puts "💡 Use this token in your Authorization header:"
      puts "Authorization: Bearer #{token.first}"
      puts "="*60
    else
      puts "❌ Error creating admin user:"
      puts admin.errors.full_messages
    end
  end
end
