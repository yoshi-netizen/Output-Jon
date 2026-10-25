require "rails_helper"

RSpec.describe "リマインドメール", type: :system do
  let(:user) { create(:user) }

  # リマインド付きの投稿を作成するメソッド（当日のリマインド日を設定）
  # 当日のリマインド日はバリデーションで登録できないため、検証をスキップして保存する
  def create_today_post(user, topic)
    post = build(:post, user: user, thinking_topic: topic, remind_date: Date.current)
    post.save!(validate: false)
    post
  end

  # 送信した内容はActionMailer::Base.deliveriesに残るため、各テストの前にメールの送信履歴をクリアする
  before { ActionMailer::Base.deliveries.clear }

  it "1通にまとまったメールのリンクから、ログイン後に投稿詳細を開けること" do
    first_post = create_today_post(user, "1つ目のテーマ")
    second_post = create_today_post(user, "2つ目のテーマ")

    # メールに載るはずのURLを先に作っておく
    first_url = "http://www.example.com/posts/#{first_post.id}"
    second_url = "http://www.example.com/posts/#{second_post.id}"

    # リマインド送信を実行する（毎朝の Cron Job と同じ処理）
    SendReminderService.new.call

    # 投稿2件が1通のメールにまとまっていること
    expect(ActionMailer::Base.deliveries.size).to eq 1

    # メール本文に、2件分のURLが両方載っていること
    body = ActionMailer::Base.deliveries.last.text_part.body.decoded
    expect(body).to include(first_url)
    expect(body).to include(second_url)

    # メールのリンクを開いた想定で、1つ目の投稿詳細を開く
    visit post_path(first_post)

    # 未ログインなのでログイン画面が出る → ログインする
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログイン"

    # メールのリンク先だった投稿詳細が表示されること
    expect(page).to have_current_path(post_path(first_post))
    expect(page).to have_content "1つ目のテーマ"
  end
end