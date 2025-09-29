require 'rails_helper'

RSpec.describe User, type: :model do
  describe "User validations" do
    it "is valid with valid attributes" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "is not valid without required fields" do
      user = User.new
      expect(user).not_to be_valid
    end
  end
end
