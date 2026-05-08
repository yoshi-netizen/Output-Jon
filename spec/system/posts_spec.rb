require 'rails_helper'

RSpec.describe "思考整理の投稿機能", type: :system do
  include LoginMacros
  let(:user) { FactoryBot.create(:user) }

  before do
    # ログインして投稿画面へ移動
    login(user)
  end

  describe "新規投稿" do
    context "入力内容が正しいとき" do
      it "投稿が成功し、成功メッセージが表示されること" do
        fill_in '整理したいテーマ', with: 'テストテーマ'
        fill_in '考えの箇条書き', with: '考えのテスト内容'
        select '【壁打ち】 モヤモヤしていることを言語化してほしい', from: '整理の目的'
        fill_in '整理した考え', with: '整理後のテスト内容'
        click_on '保存'
        # 成功メッセージが表示されるのを待つ
        expect(page).to have_content '投稿に成功しました'
        # Postモデルのレコード数が増えたか確認
        expect(Post.count).to eq 1
        # 遷移先のURL確認（redirect_to new_post_path なので同じURL）
        expect(page).to have_current_path(new_post_path)
      end
    end

    context "入力内容に不備があるとき" do
      it "保存に失敗し、エラーメッセージが表示されること" do
        # テーマを空のままにする
        fill_in '整理したいテーマ', with: ''
        expect { click_on '保存' }.not_to change(Post, :count)
        # エラーメッセージの確認（モデルのバリデーションメッセージ）
        expect(page).to have_content "Thinking topic can't be blank"
        # エラー表示エリアの文言確認
        expect(page).to have_content '件のエラーにより保存できませんでした'
      end
    end
  end
end
