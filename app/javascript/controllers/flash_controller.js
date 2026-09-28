import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // connectはフラッシュメッセージが表示されたら呼ばれる
  connect() {                              
    // data-auto-dismiss 属性が付いているときだけ、3秒後に消す。data-auto-dismissはオリジナルのカスタム属性で条件分岐用。
    if (this.element.hasAttribute("data-auto-dismiss")) {
      this.timer = setTimeout(() => this.element.remove(), 3000)
    }
  }

  // × ボタンのクリック
  close() {
    this.element.remove()
  }

  // 要素が DOM から外れたとき（close / ページ遷移）にタイマーを片付ける
  disconnect() {
    clearTimeout(this.timer)
  }
}