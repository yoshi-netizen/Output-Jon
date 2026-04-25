require 'rails_helper'

RSpec.describe "Posts", type: :request do
  # テスト用ユーザーを準備
  let(:user) { FactoryBot.create(:user) }

  describe "GET /new" do
    it "ログインしていればhttp successを返す" do
      # 1. ログインさせる（Deviseの場合）
      sign_in user 
      
      # 2. リクエストを送る
      get "/posts/new"
      
      # 3. 結果を検証する
      expect(response).to have_http_status(:success)
    end
  end
end