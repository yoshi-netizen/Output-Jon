module LoginMacros
  def login(user)
    visit new_user_session_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'

    expect(page).to have_content I18n.t('devise.sessions.signed_in')
  end
end
