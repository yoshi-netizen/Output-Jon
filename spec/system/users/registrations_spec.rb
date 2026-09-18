require 'rails_helper'

RSpec.describe "新規登録画面", type: :system do
  include NewTabMacros

  before { visit new_user_registration_path }

  it "利用規約リンクをクリックすると別タブで利用規約が表示されること" do
    within("form") { click_link "利用規約" }
    expect_new_tab_content("利用規約")
  end

  it "プライバシーポリシーリンクをクリックすると別タブでプライバシーポリシーが表示されること" do
    within("form") { click_link "プライバシーポリシー" }
    expect_new_tab_content("プライバシーポリシー")
  end
end
