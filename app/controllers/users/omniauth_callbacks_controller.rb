class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    callback_for(:line) # LINE から戻ってきたときの入口
  end

  private

  def callback_for(provider)
    auth = request.env["omniauth.auth"]
    # LINEボタンと一緒に送った値（チェックボックスを押すと "1" が送られる）
    terms_agreed = (request.env["omniauth.params"] || {})["terms_agreed"] == "1"

    user = User.from_omniauth(auth, terms_agreed: terms_agreed)

    if user.nil?
      # 未登録・未同意：作成せずに新規登録画面へ戻す
      redirect_to new_user_registration_path,
        alert: "#{provider_name(provider)}アカウントは登録できませんでした。利用規約に同意のうえ、新規登録してください。"
    elsif user.persisted?
      # ログイン
      sign_in user, event: :authentication
      flash[:notice] = "#{provider_name(provider)}でログインしました"
      redirect_to stored_location_for(user) || authenticated_root_path
    else
      # 作成に失敗（バリデーションエラーなど）
      redirect_to new_user_registration_path,
        alert: "#{provider_name(provider)}での登録に失敗しました。"
    end
  end

  def provider_name(provider)
    {
      line: "LINE"
    }.fetch(provider.to_sym, provider.to_s.titleize)
  end
end

