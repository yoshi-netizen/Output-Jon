class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # ログイン後の遷移先を投稿作成ページに設定
  # deviseのデフォルトではルートページに設定されているため
  def after_sign_in_path_for(resource)
    new_post_path
  end
end
