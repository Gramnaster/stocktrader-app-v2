require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  RSpec.describe User, type: :model do
    it "is invalid without email and " do
      user = User.new (
        email: 'avel@yahoo.com'
      )
      expect(user).not_to be_valid
    end
end
