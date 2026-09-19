class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # ログイン済みユーザーが最新の利用規約に同意していない場合、利用規約同意ページにリダイレクトする
  before_action :require_terms_agreement

  # フラッシュメッセージのタイプを追加
  add_flash_types :success, :danger

  # ログイン後の遷移先を投稿作成ページに設定
  # deviseのデフォルトではルートページに設定されているため
  def after_sign_in_path_for(resource)
    new_post_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :terms_agreed ])
  end

  def require_terms_agreement
    return unless user_signed_in?                   # ログインしていない場合は何もしない
    return if devise_controller?                    # ログアウト等を塞がないため
    return if current_user.agreed_to_current_terms? # ログイン済みユーザーが最新の利用規約に同意している場合は何もしない

    redirect_to terms_agreement_path                # 規約同意ページにリダイレクト
  end
end
