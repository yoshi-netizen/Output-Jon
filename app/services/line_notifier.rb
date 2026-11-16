# LINE Messaging API を使った通知（Push 送信・友だち確認）
class LineNotifier
  class DeliveryError < StandardError; end

  TIMEOUT_SECONDS = 5

  # テストで偽のクライアントを渡せるように、外から差し込めるようにしておく
  def initialize(client: nil)
    @client = client
  end

  # 当日のリマインド対象の投稿を、1通にまとめて Push 送信する
  # 失敗したら例外を出す（SendReminderService の rescue で拾う）
  def push_reminder(user, posts)
    request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: user.uid,
      messages: [ Line::Bot::V2::MessagingApi::TextMessage.new(text: reminder_text(posts)) ]
    )

    # push_message は失敗しても例外にならないので、ステータスコードを受け取れる _with_http_info を使う
    body, status, _headers = client.push_message_with_http_info(push_message_request: request)
    return if status == 200

    raise DeliveryError, "LINE push failed: status=#{status} body=#{body.inspect}"
  end

  # 【友だち確認について】
  # 以前は「公式アカウントを友だち追加しているか」を確認する friend? を持っていたが、
  # フォームに友だち追加リンクを常に表示する方針にしたため削除した（Issue #124）。
  # 再実装するときの参考:
  #   - 実装: git show b318f38:app/services/line_notifier.rb（friend?）
  #           git show b8c7eaf:app/models/user.rb（User#line_friend?）
  #   - 方法: Messaging API のプロフィール取得 GET /v2/bot/profile/{userId} が 200 なら友だちとみなす
  #           （未追加でも公式アカウントにメッセージを送ったことがある人は 200 になる点に注意）
  #   - 正確に判定するなら LINE ログイン API の GET /friendship/v1/status（friendFlag）。
  #     ただしユーザー本人のアクセストークンが必要で、現状は保存していない

  private

  def client
    @client ||= Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV.fetch("LINE_MESSAGING_CHANNEL_ACCESS_TOKEN"),
      http_options: { open_timeout: TIMEOUT_SECONDS, read_timeout: TIMEOUT_SECONDS }
    )
  end

  def reminder_text(posts)
    lines = [ "【Output JON】", "今日は、以前に整理した思考を振り返る日です。", "" ]
    posts.each do |post|
      lines << "■ #{post.thinking_topic}"
      lines << url_helpers.post_url(post)
      lines << ""
    end
    lines << "※リンク先を開くにはログインが必要です。"
    lines.join("\n")
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
