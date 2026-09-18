require 'rails_helper'

RSpec.describe "ルートパスとアクセス制御", type: :request do
  describe "ルートパスの出し分け" do
    describe "GET /" do
      context "未ログイン時" do                          # home#indexページが表示されること
        before { get "/" }

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "リード文が含まれる" do
          expect(response.body).to include("「また、うまく伝えられなかった…。」")
        end
      end

      context "ログイン時" do
        let(:user) { FactoryBot.create(:user) }
        before do
          sign_in user
          get "/"
        end

        it "HTTPステータス200を返す" do
          expect(response).to have_http_status(200)
        end

        it "ページタイトルが含まれる" do
          expect(response.body).to include("思考の整理")
        end
      end
    end
  end

  describe "規約同意ガード" do
    let(:user) { FactoryBot.create(:user) }

    context "一度も規約に同意したことがない場合" do
      before do
        user.update_column(:terms_accepted_at, nil)
        sign_in user
        get "/"
      end

      it "規約同意画面へリダイレクトされること" do
        expect(response).to redirect_to(terms_agreement_path)
      end
    end

    context "過去の規約バージョンには同意済みだが最新の規約には未同意の場合" do
      before do
        user.update_column(:terms_accepted_at, User::CURRENT_TERMS_UPDATED_AT - 1.day)
        sign_in user
        get "/"
      end

      it "規約同意画面へリダイレクトされること" do
        expect(response).to redirect_to(terms_agreement_path)
      end
    end

    context "最新の規約に同意済みの場合" do
      before do
        user.update_column(:terms_accepted_at, User::CURRENT_TERMS_UPDATED_AT + 1.day)
        sign_in user
        get "/"
      end

      it "規約同意画面へリダイレクトされないこと" do
        expect(response).to have_http_status(200)
      end
    end

    context "未ログインの場合" do
      before { get "/" }

      it "規約同意画面へリダイレクトされないこと" do
        expect(response).to have_http_status(200)
      end
    end
  end
end
