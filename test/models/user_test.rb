require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "user should be valid with required attributes" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User",
      date_of_birth: "1990-01-01",
      mobile_no: "1234567890",
      address_line_01: "123 Main St",
      city: "Test City",
      zip_code: "12345",
      country: countries(:one)
    )
    assert user.valid?
  end
end
