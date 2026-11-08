require 'rails_helper'

RSpec.describe "LINEログイン", type: :request do
  let(:line_uid) { "U1234567890" }

  # LINEと通信せず、callbackに認証結果（偽物）を渡す
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:line] = OmniAuth::AuthHash.new(provider: "line", uid: line_uid)
  end

  # 他のテストに影響させない
  after do
    OmniAuth.config.mock_auth[:line] = nil
    OmniAuth.config.test_mode = false
  end

  context "未登録のLINEアカウントで、規約に同意して登録した場合" do
    it "ユーザーが作成され、ログインした状態になる" do
      expect {
        post user_line_omniauth_authorize_path, params: { terms_agreed: "1" }
        follow_redirect!
      }.to change(User, :count).by(1)

      user = User.find_by(provider: "line", uid: line_uid)
      expect(user.email).to be_nil
      expect(user.terms_accepted_at).to be_present
      expect(response).to redirect_to authenticated_root_path

      get new_post_path
      expect(response).to have_http_status(:ok)
    end
  end

  context "未登録のLINEアカウントで、規約に同意していない場合" do
    # ログイン画面のLINEボタン（チェックボックスなし）から来た場合も同じ
    it "ユーザーは作成されず、新規登録画面へリダイレクトされる" do
      expect {
        post user_line_omniauth_authorize_path
        follow_redirect!
      }.not_to change(User, :count)

      expect(response).to redirect_to new_user_registration_path
    end
  end

  context "登録済みのLINEアカウントの場合" do
    before do
      create(:user, provider: "line", uid: line_uid, email: nil)
    end

    it "ユーザーは増えず、ログインした状態になる" do
      expect {
        post user_line_omniauth_authorize_path
        follow_redirect!
      }.not_to change(User, :count)

      expect(response).to redirect_to authenticated_root_path

      get new_post_path
      expect(response).to have_http_status(:ok)
    end
  end
end
