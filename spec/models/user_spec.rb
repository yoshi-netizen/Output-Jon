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

    it 'パスワードが空だと無効であること' do
      user = build(:user, password: nil, password_confirmation: nil)
      expect(user).not_to be_valid
    end

    it 'パスワードが5文字以下だと無効であること' do
      user = build(:user, password: "a" * 5, password_confirmation: "a" * 5)
      expect(user).not_to be_valid
    end

    it 'パスワードと確認用パスワードが一致しないと無効であること' do
      user = build(:user, password_confirmation: "different")
      expect(user).not_to be_valid
    end

    it 'メールアドレスが重複していると無効であること' do
      create(:user, email: "duplicate@example.com")
      user = build(:user, email: "duplicate@example.com")
      expect(user).not_to be_valid
    end

    it 'メールアドレスの形式が不正だと無効であること' do
      user = build(:user, email: "invalid-email")
      expect(user).not_to be_valid
    end
  end
end
