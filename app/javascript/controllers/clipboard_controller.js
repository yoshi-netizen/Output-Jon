import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["label", "button"];

  // コピーボタンをクリックしたらlabel「コピー」が「コピーしました」に変わり、2秒間押せなくなる
  labelchange() {
    this.buttonTarget.disabled = true;
    this.labelTarget.textContent = "コピーしました";

    this.timer = setTimeout(() => {                  // 2秒後に元に戻る
      this.buttonTarget.disabled = false;
      this.labelTarget.textContent = "コピー";
    }, 2000);
  }

  // タイマーリセット処理
  resettimer() {
    clearTimeout(this.timer);
  }

  // 接続が切れたらタイマーをリセットする
  disconnect() {
    this.resettimer();
  }
}
