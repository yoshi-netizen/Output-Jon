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

  # 公式アカウントを友だち追加しているか（プロフィールを取得できれば友だちとみなす）
  # 判定に失敗したときは false を返し、友だち追加の案内を出すようにする
  def friend?(user)
    _body, status, _headers = client.get_profile_with_http_info(user_id: user.uid)
    status == 200
  rescue StandardError => e
    Rails.logger.warn "LINE friendship check failed: user=#{user.id} #{e.class} #{e.message}"
    false
  end

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
