require 'rails_helper'

RSpec.describe "利用規約同意画面で", type: :request do
  let(:user) { create(:user) }

  before do
    user.update_column(:terms_accepted_at, nil)
  end

  context "未ログインの場合" do
    it "ログイン画面へリダイレクトされる" do        # authenticate_user!の確認
      get terms_agreement_path
      expect(response).to redirect_to new_user_session_path
    end
  end

  context "ログイン済みの場合" do
    before do
      sign_in user
    end

    context "同意チェックを入れて送信した場合" do
      before do
        patch terms_agreement_path, params: { user: { terms_agreed: "1" } }
      end

      it "同意日時が更新される" do
        expect(user.reload.terms_accepted_at).to be_present
      end

      it "投稿作成画面へリダイレクトされる" do
        expect(response).to redirect_to new_post_path
      end
    end

    context "同意チェックを外して送信した場合" do
      before do
        patch terms_agreement_path, params: { user: { terms_agreed: "0" } }
      end

      it "同意日時が更新されない" do
        expect(user.reload.terms_accepted_at).to be_nil
      end

      it "エラーメッセージが返る" do
        expect(response.body).to include("Terms agreed must be accepted")
      end
    end
  end
end
