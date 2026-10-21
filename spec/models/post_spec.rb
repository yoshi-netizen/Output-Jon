require 'rails_helper'

RSpec.describe Post, type: :model do
  # テストデータの準備
  # userを作成
  let(:user) { FactoryBot.create(:user) }
  # userに紐付いた未保存のpostを準備
  let(:post) { FactoryBot.build(:post, user: user) }

  it "有効な属性を持っていれば保存できること" do
    expect(post).to be_valid
  end

  it "テーマ名が空だと保存できないこと" do
    post.thinking_topic = ""
    expect(post).not_to be_valid
  end

  it "ユーザーが紐付いていないと保存できないこと" do
    post.user = nil
    expect(post).not_to be_valid
  end

  describe "リマインド日" do
    it "リマインド日が空でも保存できること" do
      post = build(:post, user: user, remind_date: nil)
      expect(post).to be_valid
    end

    it "リマインド日が未来日（明日以降）の場合、保存できること" do
      post = build(:post, user: user, remind_date: Date.current.tomorrow)
      expect(post).to be_valid
    end

    it "リマインド日が過去日の既存投稿は、リマインド日を変えなければ保存できること" do # remind_date_changed?が実行されない
      post = build(:post, user: user, remind_date: Date.current.yesterday, created_at: Date.current.days_ago(2))
      post.save!(validate: false)
      post.thinking_topic = "変更後のテーマ" # リマインド日以外を変更する
      expect(post).to be_valid
    end

    it "リマインド日が過去日だと保存できないこと" do
      post = build(:post, user: user, remind_date: Date.current.yesterday)
      expect(post).not_to be_valid
    end

    it "リマインド日が当日の場合、登録できないこと" do
      post = build(:post, user: user, remind_date: Date.current)
      expect(post).not_to be_valid
    end
  end

  describe "scopeの確認" do
    it "リマインド日が当日の投稿だけを返すこと" do
      # リマインド当日の投稿作成
      today_post = build(:post, user: user, remind_date: Date.current)
      today_post.save!(validate: false)
      # リマインド日過ぎの投稿作成
      yesterday_post = build(:post, user: user, remind_date: Date.current.yesterday)
      yesterday_post.save!(validate: false)
      # リマインド日が明日の投稿作成
      create(:post, user: user, remind_date: Date.current.tomorrow)
      # リマインド日なしの投稿作成
      create(:post, user: user, remind_date: nil)
      expect(Post.remindable_today).to contain_exactly(today_post) # remindable_todayで当日の投稿だけが返ることを確認
    end
  end
end
