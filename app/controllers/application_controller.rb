class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # フラッシュメッセージのタイプを追加
  add_flash_types :success, :danger

  # ログイン後の遷移先を投稿作成ページに設定
  # deviseのデフォルトではルートページに設定されているため
  def after_sign_in_path_for(resource)
    new_post_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_agreed])
  end
end
