require 'rails_helper'

RSpec.describe "規約同意画面のリンク", type: :system do
  include LoginMacros
  include NewTabMacros
  let(:user) { FactoryBot.create(:user) }

  before do
    user.update_column(:terms_accepted_at, nil)
    login(user)
  end

  it "利用規約リンクをクリックすると別タブで利用規約が表示されること" do
    click_link "利用規約を確認する"
    expect_new_tab_content("利用規約")
  end

  it "プライバシーポリシーリンクをクリックすると別タブでプライバシーポリシーが表示されること" do
    click_link "プライバシーポリシーを確認する"
    expect_new_tab_content("プライバシーポリシー")
  end
end