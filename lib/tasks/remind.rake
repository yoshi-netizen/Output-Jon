namespace :remind do
  desc "リマインド通知を送信するタスク"
  task send: :environment do
    # 当日のリマインド通知を送信する処理を呼ぶ
    SendReminderService.new.call
  end
end
