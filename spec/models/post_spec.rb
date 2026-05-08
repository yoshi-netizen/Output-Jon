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
end
