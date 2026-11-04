class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    callback_for(:line) # LINE から戻ってきたときの入口
  end

  private

  def callback_for(provider)
  # 認証結果からユーザーを取得/作成（app/models/user.rb に定義）
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      sign_in user, event: :authentication                                # ログイン
      flash[:notice] = "#{provider_name(provider)}でログインしました"
      redirect_to stored_location_for(user) || authenticated_root_path    # 元居た場所 or 投稿作成ページ
    else
      session["devise.#{provider}_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_session_path, alert: "ユーザー情報の取得に失敗しました。"
    end
  end

  def provider_name(provider)
    {
      line: "LINE"
    }.fetch(provider.to_sym, provider.to_s.titleize)
  end
end
