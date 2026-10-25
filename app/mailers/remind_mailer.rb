class RemindMailer < ApplicationMailer
  # 当日がリマインド日の投稿を、ユーザーごとに1通にまとめて送る
  def reminder
    @user = params[:user]
    @posts = params[:posts]

    mail(
      to: @user.email,
      subject: "【Output JON】今日振り返る思考が#{@posts.size}件あります"
    )
  end
end
