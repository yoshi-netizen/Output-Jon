require 'rails_helper'

RSpec.describe "パスワードリセット", type: :system do
  let(:user) { create(:user) }
  before { ActionMailer::Base.deliveries.clear }

  it "再設定メールのリンクからパスワードを変更し、新しいパスワードでログインできること" do
    visit new_user_session_path
    click_link "パスワードをお忘れの場合はこちらをクリックしてください"
    fill_in "メールアドレス", with: user.email
    click_button "再設定メールを送信する"
    expect(page).to have_content I18n.t('devise.passwords.send_paranoid_instructions')
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.from).to eq([ "no-reply@output-jon.tech" ])
    expect(mail.to).to eq([ user.email ])
    html = Capybara.string(mail.body.decoded)
    url = html.find_link("パスワードを再設定する")[:href] # メール内のパスワード再設定リンクのURLを取得
    visit URI.parse(url).request_uri   # => "/users/password/edit?reset_password_token=…" テスト環境ではフルURLではなくパス部分のみを使用
    fill_in "新しいパスワード", with: "newpassword"
    fill_in "新しいパスワード（確認）", with: "newpassword"
    click_button "パスワードを変更する"
    expect(page).to have_content I18n.t('devise.passwords.updated')
    Capybara.reset_sessions! # セッションをリセットしてログアウト状態にする
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "newpassword"
    click_button "ログイン"
    expect(page).to have_content I18n.t('devise.sessions.signed_in')
  end

  it "未登録のメールアドレスでも同じメッセージが表示され、メールは送信されないこと" do
    visit new_user_password_path
    fill_in "メールアドレス", with: "unknown@example.com"
    click_button "再設定メールを送信する"
    expect(page).to have_content I18n.t('devise.passwords.send_paranoid_instructions')
    expect(ActionMailer::Base.deliveries.size).to eq(0)
  end

  it "不正なトークンではパスワードを変更できないこと" do
    visit edit_user_password_path(reset_password_token: "invalid_token")
    fill_in "新しいパスワード", with: "newpassword"
    fill_in "新しいパスワード（確認）", with: "newpassword"
    click_button "パスワードを変更する"
    expect(page).to have_content I18n.t('activerecord.attributes.user.reset_password_token')
  end
end
