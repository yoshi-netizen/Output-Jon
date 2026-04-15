require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    it 'メールアドレスとパスワードがあれば有効であること' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'メールアドレスが空だと無効であること' do
      user = build(:user, email: nil)
      user.valid?
    expect(user.errors[:email]).to include("can't be blank")
    end
  end
end
