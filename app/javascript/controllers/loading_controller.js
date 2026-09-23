import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label", "spinner"]

  start(event) {
    if (event.detail.formSubmission.submitter !== this.buttonTarget) return    // 押されたボタンが「AIで整理する」か確認。保存ボタンでは実行されない。
    this.labelTarget.classList.add("hidden")
    this.spinnerTarget.classList.remove("hidden")
  }

  end() {
    this.labelTarget.classList.remove("hidden")
    this.spinnerTarget.classList.add("hidden")
  }
}