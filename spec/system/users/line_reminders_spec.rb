require "rails_helper"

RSpec.describe "LINEリマインド", type: :system do
  let(:user)      { create(:user) }       # メールのユーザー
  let(:line_user) { create(:line_user) }  # LINEのユーザー

  # 当日のリマインド日はバリデーションで登録できないため、検証をスキップして保存する
  def create_today_post(user, topic)
    post = build(:post, user: user, thinking_topic: topic, remind_date: Date.current)
    post.save!(validate: false)
    post
  end

  describe "友だち追加リンクの表示" do
    context "LINEユーザーの場合" do
      before { sign_in line_user }

      it "新規投稿ページに、別タブで開く友だち追加リンクが表示されること" do
        visit new_post_path
        expect(page).to have_link "友だち追加", href: "https://lin.ee/zxRbHNy", target: "_blank"
      end

      it "編集ページにも、友だち追加リンクが表示されること" do
        post = create(:post, user: line_user)
        visit edit_post_path(post)
        expect(page).to have_link "友だち追加", href: "https://lin.ee/zxRbHNy"
      end
    end

    context "メールのユーザーの場合" do
      before { sign_in user }

      it "友だち追加リンクが表示されないこと" do
        visit new_post_path
        expect(page).not_to have_link "友だち追加"
      end
    end
  end

  describe "リマインドの送信" do
    # 本物のLINEに送らないよう、LineNotifier を偽物に差し替える
    let(:notifier) { instance_double(LineNotifier) }

    before do
      # LineNotifier のインスタンスをstubに差し替える
      allow(LineNotifier).to receive(:new).and_return(notifier)
      ActionMailer::Base.deliveries.clear
    end

    context "LINEへの送信に成功した場合" do
      before { allow(notifier).to receive(:push_reminder) }

      it "LINEユーザーにはLINEで、メールのユーザーにはメールで送られること" do
        create_today_post(line_user, "LINEのテーマ")
        create_today_post(user, "メールのテーマ")

        SendReminderService.new.call

        expect(notifier).to have_received(:push_reminder)
        expect(ActionMailer::Base.deliveries.size).to eq 1
      end

      it "送信した投稿のリマインド日が消えること" do
        line_post = create_today_post(line_user, "LINEのテーマ")

        SendReminderService.new.call

        expect(line_post.reload.remind_date).to be_nil
      end
    end

    context "LINEへの送信に失敗した場合" do
      before { allow(notifier).to receive(:push_reminder).and_raise(LineNotifier::DeliveryError) }

      it "他のユーザーへの送信は続き、失敗した投稿のリマインド日は残ること" do
        # LINEユーザーを先に処理させるため、LINEの投稿を先に作る
        line_post = create_today_post(line_user, "LINEのテーマ")
        create_today_post(user, "メールのテーマ")

        SendReminderService.new.call

        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(line_post.reload.remind_date).to eq Date.current
      end
    end
  end

  describe "LINEに送る内容" do
    # LINEのAPIクライアントを偽物にして、送ろうとした内容を受け取る
    let(:client)   { instance_double(Line::Bot::V2::MessagingApi::ApiClient) }
    let(:notifier) { LineNotifier.new(client: client) }

    it "ユーザー宛てに、投稿のテーマとリンクを送ること" do
      post = create_today_post(line_user, "LINEのテーマ")

      sent_request = nil
      allow(client).to receive(:push_message_with_http_info) do |push_message_request:|
        sent_request = push_message_request
        [ nil, 200, {} ]
      end

      notifier.push_reminder(line_user, [ post ])

      expect(sent_request.to).to eq line_user.uid
      text = sent_request.messages.first.text
      expect(text).to include("LINEのテーマ", "http://www.example.com/posts/#{post.id}")
    end

    it "LINEが200以外を返したら、送信失敗のエラーになること" do
      post = create_today_post(line_user, "テーマ")
      allow(client).to receive(:push_message_with_http_info).and_return([ "error", 401, {} ])

      expect { notifier.push_reminder(line_user, [ post ]) }.to raise_error(LineNotifier::DeliveryError)
    end
  end
end
