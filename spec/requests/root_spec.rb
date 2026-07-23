require 'rails_helper'

RSpec.describe "ルートパスの出し分け", type: :request do
  
  describe "GET /" do
    context "未ログイン時" do                          # home#indexページが表示されること
      before { get "/" }
      
      it "HTTPステータス200を返す" do                                    
        expect(response).to have_http_status(200)
      end
      
      it "ログインへのリンクが含まれる" do
        expect(response.body).to include(new_user_session_path)
      end

      it "新規登録へのリンクが含まれる" do
        expect(response.body).to include(new_user_registration_path)
      end
      
      it "リード文が含まれる" do
        expect(response.body).to include("「また、うまく伝えられなかった…。」")
      end

    end

    context "ログイン時" do                            # posts#new
    let(:user) { FactoryBot.create(:user) }
    before do
      sign_in user     
      get "/"
    end
      
      it "HTTPステータス200を返す" do                                    
        expect(response).to have_http_status(200)
      end
      
      it "ログアウトのリンクが含まれる" do
        expect(response.body).to include(destroy_user_session_path)
      end
      
      it "ページタイトルが含まれる" do
        expect(response.body).to include("思考の整理")
      end
      
    end
  end
end