class PostsController < ApplicationController
  # アクションを実行する前にログインしているかチェックし、していなければログインしてページへリダイレクトする
  before_action :authenticate_user!

  def new
    # 空のPostインスタンスを作成し、ビューに渡す
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
        redirect_to new_post_path, notice: "投稿に成功しました"
    else
      render "new", status: :unprocessable_entity
    end
  end

  def index
    @posts = current_user.posts.includes(:user).order(created_at: :desc)
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
      render :edit, status: :unprocessable_entity
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

  def post_params  # ストロングパラメータ
    params.require(:post).permit(:thinking_topic, :thinking_diffusion, :thinking_core, :thinking_output) # パラメーターのキー
  end
end
