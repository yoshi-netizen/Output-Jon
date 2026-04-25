Rails.application.routes.draw do
  devise_for :users
  # 以下のようなルーティングが自動的に設定されます:
  # サインアップ (/users/sign_up)
  # ログイン (/users/sign_in)
  # サインアウト (/users/sign_out)
  # パスワードリセット (/users/password/new, /users/password/editなど)

  # https://guides.rubyonrails.org/routing.html の DSL に従ってアプリケーションのルートを定義します。
  
  # /up でヘルスステータスを表示します。アプリケーションが例外なく起動した場合は 200、それ以外の場合は 500 を返します。
  # ロードバランサーや稼働状況モニターで、アプリケーションが稼働していることを確認するために使用できます。
  get "up" => "rails/health#show", as: :rails_health_check

  # app/views/pwa/* から動的なPWAファイルをレンダリングします。
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # ルート パス ("/") を以下のように定義します。
  # root "posts#index"

  # トップ画面（サイトのルートURL "/" にアクセスした時の設定）
  root "home#index"

  resources :posts, only: [:new, :create]
end
