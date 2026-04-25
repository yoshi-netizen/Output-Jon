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
      redirect_to new_post_path, notice: '投稿に成功しました'
    else
      flash.now[:alert] = '投稿に失敗しました' 
      render 'new', status: :unprocessable_entity # Rails 7以降の推奨
    end
  end

  private

  def post_params  #ストロングパラメータ
    params.require(:post).permit(:thinking_topic) #パラメーターのキー
  end 
end
