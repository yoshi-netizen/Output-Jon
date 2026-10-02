import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["label", "button", "text"];

  // コピーボタンをクリックしたらlabel「コピー」が「コピーしました」に変わり、2秒間押せなくなる
  labelchange() {
    this.buttonTarget.disabled = true;
    this.labelTarget.textContent = "コピーしましたcheck";

    this.timer = setTimeout(() => {                  // 2秒後に元に戻る
      this.buttonTarget.disabled = false;
      this.labelTarget.textContent = "コピーcontent_copy";
    }, 2000);
  }

  // Promiseでクリップボードにコピー後にラベルを変更する
  copy() {
    const text = this.textTarget.value;
    navigator.clipboard.writeText(text)
    .then(() => {
      this.labelchange();
    })
    .catch((error) => {
      console.error("コピーに失敗しました:", error);
    });
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
