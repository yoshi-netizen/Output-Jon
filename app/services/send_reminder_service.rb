class SendReminderService
  def call
    # 当日のリマインド対象の投稿を取得
    posts = Post.remindable_today.includes(:user)

    # ユーザーごとに投稿をまとめる { user => [post, post], ... }
    posts_by_user = posts.group_by(&:user)

    # ユーザー1人につき1回だけ送信する
    posts_by_user.each do |user, user_posts|
      send_reminder(user, user_posts, notification_channel(user))
    end
  end

  private

  def send_reminder(user, posts, channel)
    if channel == :email
      RemindMailer.with(user: user, posts: posts).reminder.deliver_now
      Post.where(id: posts.map(&:id)).update_all(remind_date: nil) # リマインド済みとしてremind_dateをクリア
      Rails.logger.info "Sent reminder email to user: #{user.id}, posts: #{posts.map(&:id)}"
    else
      Rails.logger.warn "No notification channel for user: #{user.id}"
    end
  rescue StandardError => e
    # 1人の送信に失敗しても、他のユーザーへの送信は続ける
    Rails.logger.error "Failed to send reminder to user: #{user.id}, error: #{e.class} #{e.message}"
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
