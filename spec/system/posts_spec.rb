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

  describe '投稿一覧機能', type: :system do
    context '一覧表示の確認' do
      # ログインユーザーの投稿を複数作成（let!で事前に作成）
      let!(:my_post) { FactoryBot.create(:post, user: user, thinking_topic: '自分の投稿') }
      let!(:old_post) { FactoryBot.create(:post, user: user, thinking_topic: '古い投稿', created_at: 1.day.ago) }
      # 他人の投稿を作成
      let!(:others_post) { FactoryBot.create(:post, thinking_topic: '他人の投稿') }

      before do
        visit posts_path
      end

      it 'ログインユーザーの投稿のみが表示され、他人の投稿は表示されないこと' do
        expect(page).to have_content '自分の投稿'
        expect(page).to have_content '古い投稿'
        expect(page).not_to have_content '他人の投稿'
      end

      it '投稿が新しい順（作成日時の降順）に表示されていること' do
        # 「自分の投稿」が「古い投稿」より上にあるか確認
        # page.body.index を使うと、HTML内に出現する順番を数値で比較できる
        expect(page.body.index('自分の投稿')).to be < page.body.index('古い投稿')
      end
    end

    context '投稿がない場合' do
      it '適切なメッセージが表示されること' do
        visit posts_path
        expect(page).to have_content 'まだ投稿がありません'
        expect(page).to have_link '思考を整理する', href: new_post_path
      end
    end
  end
end
