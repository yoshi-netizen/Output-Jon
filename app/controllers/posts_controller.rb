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
      render "new", status: :unprocessable_entity # Rails 7以降の推奨 HTTPステータスコード422を返す
    end
  end

  def index
    @posts = current_user.posts.includes(:user).order(created_at: :desc)
  end

  def show
    @post = current_user.posts.find(params[:id])
  end

  private

  def post_params  # ストロングパラメータ
    params.require(:post).permit(:thinking_topic, :thinking_diffusion, :thinking_core, :thinking_output) # パラメーターのキー
  end
end
