require "capybara/rspec"                                  # Capybara の RSpec 連携を読み込む
require "selenium-webdriver"                              # Selenium を読み込み、Selenium::WebDriver 系の定数を使えるようにする

Capybara.default_max_wait_time = 10                       # 要素待ちの上限を10秒に。CIの高負荷で間欠失敗するのを防ぐ（成功テストには無害）

# --- docker開発環境用ドライバ：別コンテナのChromeにリモート接続 ---
Capybara.register_driver :remote_chrome do |app|          # :remote_chrome という名前でドライバを登録。app=テスト対象のRackアプリ
  options = Selenium::WebDriver::Chrome::Options.new      # Chrome の起動オプションを組み立てる入れ物を作る
  options.add_argument("no-sandbox")                      # サンドボックス無効化（コンテナ内でChromeを動かすのに必要）
  options.add_argument("headless")                        # 画面なし（ヘッドレス）で起動
  options.add_argument("disable-gpu")                     # GPUアクセラレーション無効（ヘッドレスでの安定化）
  options.add_argument("window-size=1680,1050")           # 仮想ウィンドウのサイズを指定
  Capybara::Selenium::Driver.new(                         # このドライバの実体を生成（ブロックの戻り値＝登録内容になる）
    app,                                                  # テスト対象アプリ
    browser: :remote,                                     # 「リモートのChromeに繋ぐ」モード
    url: ENV["SELENIUM_DRIVER_URL"],                      # 繋ぎ先＝docker の chrome コンテナ(:4444)
    capabilities: options                                 # 上で作ったオプションを適用
  )
end

# --- CI/ローカル直接実行用ドライバ：その場でChromeを起動 ---
Capybara.register_driver :headless_chrome do |app|        # :headless_chrome という名前で別のドライバを登録
  options = Selenium::WebDriver::Chrome::Options.new      # 同じくオプションの入れ物を作る
  options.add_argument("--headless=new")                  # ヘッドレスで起動（Chrome現行の推奨形）
  options.add_argument("--no-sandbox")                    # サンドボックス無効化（CIランナーで必要）
  options.add_argument("--disable-gpu")                   # GPU無効
  options.add_argument("--window-size=1680,1050")         # ウィンドウサイズ指定
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)  # browser: :chrome＝同じマシンのChromeを直接起動（remoteではない）
end

RSpec.configure do |config|                               # RSpec全体の設定
  config.before(:each, type: :system) do                  # system spec の各テスト直前に、この中を実行する
    if ENV["SELENIUM_DRIVER_URL"].present?                # 環境変数がある＝docker環境か判定
      driven_by :remote_chrome                            # dockerの場合、リモートのChromeコンテナを使う
      Capybara.server_host = IPSocket.getaddress(Socket.gethostname)  # テスト用アプリを、別コンテナのChromeから届くIPで公開
      Capybara.server_port = 4444                         # そのアプリのポートを固定
      Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"  # ChromeがアクセスすべきアプリのURLを組み立てる
    else                                                  # 環境変数が無い＝CI/ローカル直接実行
      driven_by :headless_chrome                          # その場のChromeを使う（server_host等はCapybara既定に任せる）
    end
    Capybara.ignore_hidden_elements = false               # 非表示要素も操作対象に含める（両環境共通の設定）
  end
end
