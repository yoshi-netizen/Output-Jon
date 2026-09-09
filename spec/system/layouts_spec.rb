require 'rails_helper'

RSpec.describe "レイアウト共通要素", type: :system do
  include LoginMacros
  let(:user) { FactoryBot.create(:user) }

  describe "ヘッダー" do
    context "未ログイン時" do
      it "「ログイン」、「新規登録」が表示されること" do
        visit unauthenticated_root_path
        within("header") do
          expect(page).to have_link('ログイン')
          expect(page).to have_link('新規登録')
        end
      end
    end

    context 'ログイン時' do
      before { login(user) }

      it '「思考整理」、「思考一覧」、「ログアウト」が表示され、「ログイン」「新規登録」が非表示であること' do
        within("header") do
          expect(page).to have_link('思考整理')
          expect(page).to have_link('思考一覧')
          expect(page).to have_link('ログアウト')
          expect(page).to have_no_link('ログイン')
          expect(page).to have_no_link('新規登録')
        end
      end

      it "「思考整理」リンクをクリックすると新規投稿ページへ遷移すること" do
        visit posts_path # 別のページから遷移することを確認するため、あえて別の場所へ
        within("header") { click_link '思考整理', visible: true }
        expect(page).to have_current_path(new_post_path)
      end

      it "「思考一覧」リンクをクリックすると投稿一覧ページへ遷移すること" do
        within("header") { click_link '思考一覧', visible: true }
        expect(page).to have_current_path(posts_path)
      end
    end

    describe "ログアウト機能" do
      it 'ログアウトをクリックするとログアウトし、ルートページへリダイレクトされること' do
        login(user)
        within("header") { click_link 'ログアウト', visible: true }
        expect(page).to have_content ('Signed out successfully.')
        expect(page).to have_current_path(unauthenticated_root_path)
        expect(page).to have_link ('ログイン')
      end
    end

    describe "ロゴによるページ遷移" do
      it 'ヘッダーのロゴをクリックしたとき、ルートページへ遷移すること' do
        visit new_user_session_path # 別のページから遷移することを確認するため、あえて別の場所へ
        within("header") { click_on 'Output JON' }
        expect(page).to have_current_path(unauthenticated_root_path)
      end
    end
  end

  describe "フッター" do
    context "未ログイン時" do
      before { visit unauthenticated_root_path }

      it "利用規約リンクをクリックすると利用規約ページが表示されること" do
        within("footer") { click_link "利用規約" }
        expect(page).to have_current_path(terms_path)
      end

      it "プライバシーポリシーリンクをクリックするとプライバシーポリシーページが表示されること" do
        within("footer") { click_link "プライバシーポリシー" }
        expect(page).to have_current_path(privacy_policy_path)
      end
    end

    context "ログイン時" do
      before { login(user) }

      it "利用規約リンクをクリックすると利用規約ページが表示されること" do
        within("footer") { click_link "利用規約" } 
        expect(page).to have_current_path(terms_path)
      end

      it "プライバシーポリシーリンクをクリックするとプライバシーポリシーページが表示されること" do
        within("footer") { click_link "プライバシーポリシー" }
        expect(page).to have_current_path(privacy_policy_path)
      end
    end
  end
end
