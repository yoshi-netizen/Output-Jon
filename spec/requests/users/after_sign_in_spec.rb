require "rails_helper"

RSpec.describe "ログイン後の遷移先", type: :request do
  let(:user) { create(:user) }
  let(:login_params) { { user: { email: user.email, password: "password" } } }

  it "未ログインで投稿詳細を開いた場合、ログイン後にその投稿詳細へ戻ること" do
    remind_post = create(:post, user: user)
    get post_path(remind_post)
    post user_session_path, params: login_params
    expect(response).to redirect_to(post_path(remind_post))
  end

  it "ログイン画面から直接ログインした場合、投稿作成ページへ移動すること" do
    post user_session_path, params: login_params
    expect(response).to redirect_to(new_post_path)
  end
end