require 'rails_helper'

RSpec.describe "LINEログイン", type: :system do
  # LINEと通信せず、callbackに認証結果（偽物）を渡す
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:line] = OmniAuth::AuthHash.new(provider: "line", uid: "U1234567890")
  end

  # 他のテストに影響させない
  after do
    OmniAuth.config.mock_auth[:line] = nil
    OmniAuth.config.test_mode = false
  end

  context "未登録のLINEアカウントの場合" do
    it "新規登録画面で規約に同意してLINEボタンを押すと、ユーザーが作成されてログインできること" do
      visit new_user_registration_path
      check "line_terms_agreed"

      expect {
        click_button "LINEでログイン"
        expect(page).to have_content "LINEでログインしました"
      }.to change(User, :count).by(1)
    end

    it "ログイン画面でLINEボタンを押すと、ログインできないこと" do
      visit new_user_session_path
      click_button "LINEでログイン"
      expect(page).to have_content "LINEアカウントは登録できませんでした"
      expect(page).to have_current_path new_user_registration_path
    end
  end

  context "登録済みのLINEアカウントの場合" do
    before do
      create(:user, provider: "line", uid: "U1234567890", email: nil)
    end

    it "ログイン画面でLINEボタンを押すと、ログインできること" do
      visit new_user_session_path
      click_button "LINEでログイン"

      expect(page).to have_content "LINEでログインしました"
    end
  end
end
