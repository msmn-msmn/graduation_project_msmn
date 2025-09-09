require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    it 'usernameが必須であること' do
      user = User.new(email: 'test@example.com', password: 'password')
      expect(user).not_to be_valid
      # :blank（未入力）エラーが付いているか
      expect(user.errors.of_kind?(:username, :blank)).to be true
      # 長さエラー（最小値は実アプリの値に合わせて）
      expect(user.errors.of_kind?(:username, :too_short)).to be true
    end

    it 'emailが必須であること（Deviseによる）' do
      user = User.new(username: 'testuser', password: 'password')
      expect(user).not_to be_valid
      expect(user.errors.of_kind?(:email, :blank)).to be true
    end
  end
  pending "add some examples to (or delete) #{__FILE__}"
end
