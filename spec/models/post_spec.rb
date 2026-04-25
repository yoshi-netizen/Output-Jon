require 'rails_helper'

RSpec.describe Post, type: :model do
  # テストデータの準備（FactoryBotを使っている場合を想定）
  let(:user) { User.create(email: "test@example.com", password: "password") }
  let(:post) { Post.new(thinking_topic: "テストのテーマ", user: user) }

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
end
