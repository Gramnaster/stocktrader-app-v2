namespace :admin do
  desc "Create an admin user"
  task :create_user, [ :email, :password ] => :environment do |task, args|
    email = args[:email] || ENV["ADMIN_EMAIL"]
    password = args[:password] || ENV["ADMIN_PASSWORD"]

    if email.blank?
      puts "Error: Email is required. Usage:"
      puts "  rails admin:create_user[admin@example.com,password123]"
      puts "  or set ADMIN_EMAIL and ADMIN_PASSWORD environment variables"
      exit 1
    end

    if password.blank?
      puts "Error: Password is required. Usage:"
      puts "  rails admin:create_user[admin@example.com,password123]"
      puts "  or set ADMIN_EMAIL and ADMIN_PASSWORD environment variables"
      exit 1
    end

    if User.exists?(email: email)
      puts "Error: User with email #{email} already exists"
      exit 1
    end

    # Find a default country for the admin user
    default_country = Country.first
    if default_country.nil?
      puts "Error: No countries found in database. Please run 'rails db:seed' first"
      exit 1
    end

    admin_user = User.create!(
      email: email,
      password: password,
      password_confirmation: password,
      first_name: "System",
      last_name: "Administrator",
      date_of_birth: 30.years.ago,
      mobile_no: "1234567890",
      address_line_01: "123 Admin Street",
      city: "Admin City",
      zip_code: "12345",
      country: default_country,
      user_role: "admin",
      user_status: "approved",
      confirmed_at: Time.current
    )

    puts "✅ Admin user created successfully!"
    puts "   Email: #{admin_user.email}"
    puts "   Role: #{admin_user.user_role}"
    puts "   Status: #{admin_user.user_status}"
    puts ""
    puts "You can now sign in with these credentials."
  end

  desc "Promote existing user to admin"
  task :promote_user, [ :email ] => :environment do |task, args|
    email = args[:email]

    if email.blank?
      puts "Error: Email is required. Usage:"
      puts "  rails admin:promote_user[user@example.com]"
      exit 1
    end

    user = User.find_by(email: email)
    if user.nil?
      puts "Error: User with email #{email} not found"
      exit 1
    end

    if user.admin?
      puts "User #{email} is already an admin"
      exit 0
    end

    user.update!(
      user_role: "admin",
      user_status: "approved"
    )

    puts "✅ User promoted to admin successfully!"
    puts "   Email: #{user.email}"
    puts "   Role: #{user.user_role}"
    puts "   Status: #{user.user_status}"
  end

  desc "Create admin user through console (interactive)"
  task create_interactive: :environment do
    puts "=== Create Admin User ==="
    print "Email: "
    email = $stdin.gets.chomp

    print "Password: "
    password = $stdin.noecho(&:gets).chomp
    puts # New line after hidden password input

    print "First Name: "
    first_name = $stdin.gets.chomp

    print "Last Name: "
    last_name = $stdin.gets.chomp

    if User.exists?(email: email)
      puts "Error: User with email #{email} already exists"
      exit 1
    end

    # Find a default country for the admin user
    default_country = Country.first
    if default_country.nil?
      puts "Error: No countries found in database. Please run 'rails db:seed' first"
      exit 1
    end

    admin_user = User.create!(
      email: email,
      password: password,
      password_confirmation: password,
      first_name: first_name,
      last_name: last_name,
      date_of_birth: 30.years.ago,
      mobile_no: "1234567890",
      address_line_01: "123 Admin Street",
      city: "Admin City",
      zip_code: "12345",
      country: default_country,
      user_role: "admin",
      user_status: "approved",
      confirmed_at: Time.current
    )

    puts "✅ Admin user created successfully!"
    puts "   Email: #{admin_user.email}"
    puts "   Name: #{admin_user.first_name} #{admin_user.last_name}"
    puts "   Role: #{admin_user.user_role}"
    puts "   Status: #{admin_user.user_status}"
  end
end
