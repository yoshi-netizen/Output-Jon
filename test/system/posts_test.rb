require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  # # ログイン処理
  # setup do
  #   @user = users(:one) # test/fixtures/users.yml に定義されているユーザー
  #   login_as @user      # deviseなどを使っている場合のログイン補助メソッド
  # end

  # test "新規投稿テーマを作成できる" do
  #   visit new_post_path

  #   fill_in "考えたいテーマ", with: "今後のキャリアについて"
  #   click_on "Create Pos" # ボタンのテキストに合わせてください

  #   assert_text "投稿に成功しました"
  # end

  # test "テーマ名が空だと保存できない" do
  #   visit new_post_path

  #   fill_in "考えたいテーマ", with: ""
  #   click_on "登録する"

  #   assert_text "投稿に失敗しました"
  # end
end