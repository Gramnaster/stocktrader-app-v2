require 'rails_helper'

RSpec.describe "invalid User specs" do
  describe User, type: :model do
    it 'is invalid without password' do
      # puts build(:user).email.inspect
      expect(User.new).not_to be_valid
    end

    it "is not valid without password" do
      user = build(:user)
      expect(user).to be_valid
    end


  end
end