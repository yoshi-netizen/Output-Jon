module NewTabMacros
  # 直前の操作で開いた別タブの内容を検証し、タブを閉じる
  def expect_new_tab_content(content)
    new_tab = windows.last
    within_window(new_tab) do
      expect(page).to have_content(content)
    end
    new_tab.close
  end
end