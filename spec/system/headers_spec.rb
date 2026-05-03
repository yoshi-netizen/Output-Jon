require 'rails_helper'

RSpec.describe "ヘッダー", type: :system do
  include LoginMacros
  let(:user) { FactoryBot.create(:user) }
  
  describe "表示の確認" do
    context "未ログイン時" do
      it "「ログイン」、「新規登録」が表示されること" do
        visit root_path
        expect(page).to have_link('ログイン')
        expect(page).to have_link('新規登録')
      end
    end

    context 'ログイン時' do
      it '「思考整理」、「思考一覧」、「ログアウト」が表示され、「ログイン」「新規登録」が非表示であること' do
        login(user)
        expect(page).to have_link('思考整理')
        expect(page).to have_link('思考一覧')
        expect(page).to have_link('ログアウト')
        expect(page).to have_no_link('ログイン')
        expect(page).to have_no_link('新規登録')
      end
    end  
  end

  describe "ログアウト機能" do
    it 'ログアウトをクリックするとログアウトし、ルートページへリダイレクトされること' do
      login(user)
      click_link 'ログアウト'
      # ログアウト後の検証
      expect(page).to have_content ('Signed out successfully.' )
      expect(current_path).to eq root_path
      expect(page).to have_link ('ログイン')
    end
  end

  describe "ロゴによるページ遷移" do
    it 'ヘッダーのロゴをクリックしたとき、ルートページへ遷移すること' do
      visit new_user_session_path # 別のページから遷移することを確認するため、あえて別の場所へ
      click_on('Output JON')
      expect(page).to have_current_path(root_path)
    end
  end
end