class SendReminderService
  def call
    # 当日のリマインド通知を送信する処理をここに実装
    posts = Post.remindable_today.includes(:user) # 当日のリマインド対象の投稿を取得

    # 対象者を取得してログに出力
    posts.each do |post|
      user = post.user # 対象のユーザーを取得
      send_reminder(user, post, notification_channel(user))
    end
  end

  private

  def send_reminder(user, post, channel)
    # 実際のリマインド通知を送信する処理をここに実装
    Rails.logger.info "Sending reminder to user: #{user.id}, post: #{post.id}, channel: #{channel}"
  end

  # ユーザー通知手段を決める
  def notification_channel(user)
    if user.email.present?
      :email
    else
      :unknown
    end
  end
end
