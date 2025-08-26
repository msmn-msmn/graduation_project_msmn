require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    it 'usernameが必須であること' do
      user = User.new(email: 'test@example.com', password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it 'emailが必須であること（Deviseによる）' do
      user = User.new(username: 'testuser', password: 'password')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end
  end
  pending "add some examples to (or delete) #{__FILE__}"
end
