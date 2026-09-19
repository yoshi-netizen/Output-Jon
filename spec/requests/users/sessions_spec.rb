require 'rails_helper'

RSpec.describe "ログイン・ログアウトと同意日時", type: :request do
  let(:user) { FactoryBot.create(:user) }

  before { user.update_column(:terms_accepted_at, nil) }

  # Deviseのremember_me!はsave(validate: false)で保存するため、
  # before_saveにif: :terms_agreed?が無いと同意していなくても同意日時が記録されてしまっていた
  it "「ログイン状態を保持する」にチェックを入れてログインしても、同意日時が更新されないこと" do
    post user_session_path, params: { user: { email: user.email, password: "password", remember_me: "1" } }
    expect(user.reload.terms_accepted_at).to be_nil
  end

  # forget_me!も同様にsave(validate: false)で保存され、
  # expire_all_remember_me_on_sign_out=trueのためサインアウトのたびに必ず呼ばれる
  it "ログアウトしても、同意日時が更新されないこと" do
    post user_session_path, params: { user: { email: user.email, password: "password" } }
    delete destroy_user_session_path
    expect(user.reload.terms_accepted_at).to be_nil
  end
end
