Rails.application.routes.draw do
  devise_for :users, skip: [ :passwords, :registrations ]
  devise_scope :user do
    get  "/users/sign_up", to: "devise/registrations#new",    as: :new_user_registration
    post "/users",         to: "devise/registrations#create",  as: :user_registration
  end
  # 以下のようなルーティングが自動的に設定されます:
  # サインアップ (/users/sign_up)
  # ログイン (/users/sign_in)
  # サインアウト (/users/sign_out)
  # パスワードリセット (/users/password/new, /users/password/editなど)　⚠️⚠️⚠️現在、外している⚠️⚠️⚠️

  # https://guides.rubyonrails.org/routing.html の DSL に従ってアプリケーションのルートを定義します。

  # /up でヘルスステータスを表示します。アプリケーションが例外なく起動した場合は 200、それ以外の場合は 500 を返します。
  # ロードバランサーや稼働状況モニターで、アプリケーションが稼働していることを確認するために使用できます。
  get "up" => "rails/health#show", as: :rails_health_check

  # app/views/pwa/* から動的なPWAファイルをレンダリングします。
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  authenticated :user do
    root to: "posts#new", as: :authenticated_root
  end

  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end

  resources :posts, only: [ :new, :create, :index, :show, :edit, :update, :destroy ] do
    collection do
      post :generate_summary # AIによる要約生成のルーティングを追加
    end
  end
end
