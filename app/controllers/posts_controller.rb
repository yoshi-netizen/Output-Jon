class PostsController < ApplicationController
  # アクションを実行する前にログインしているかチェックし、していなければログインしてページへリダイレクトする
  before_action :authenticate_user!
  # AI生成（generate_summary）は、同じユーザーにつき1分間に2回まで実行できる
  rate_limit to: 2, within: 1.minute,
             by: -> { current_user.id },         # ユーザーごとに回数を数える
             with: -> { rate_limit_exceeded },   # 上限を超えたときに実行する処理（privateに定義）
             only: :generate_summary

  def new
    # 空のPostインスタンスを作成し、ビューに渡す
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
        redirect_to new_post_path, notice: "投稿に成功しました"
    else
      flash.now[:alert] = "投稿に失敗しました"
      render "new", status: :unprocessable_content
    end
  end

  def index
    @q = current_user.posts.ransack(params[:q])
    @posts = @q.result.order(created_at: :desc)
  end

  def show
    @post = current_user.posts.find(params[:id])
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      redirect_to post_path(@post), notice: "投稿を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "投稿を削除しました"
  end

  def generate_summary
    @post = current_user.posts.new(post_params) # 新しいPostインスタンスを作成し、フォームから送信されたパラメータを設定
    gemini = GeminiService.new          # GeminiServiceクラスのインスタンスを作成
    @summary = gemini.call(             # GeminiServiceのcallメソッドを呼び出し、レスポンスを@summaryに格納
    topic:     @post.thinking_topic,
    diffusion: @post.thinking_diffusion,
    core:      @post.thinking_core
    )
  end

  private

  # レート制限に引っかかったときの応答（ここで応答を返すので、generate_summary は実行されない）
  def rate_limit_exceeded
    flash.now[:alert] = "短時間に多くのリクエストが発生しました。少し待ってから再試行してください。"
    render :rate_limited, status: :too_many_requests # rate_limited.turbo_stream.erb を 429 で返す
  end

  def post_params  # ストロングパラメータ
    params.require(:post).permit(:thinking_topic, :thinking_diffusion, :thinking_core, :thinking_output) # パラメーターのキー
  end
end
