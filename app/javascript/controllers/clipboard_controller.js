import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["source", "button"]

  copy() {
    const text = this.sourceTarget.value

    navigator.clipboard.writeText(text).then(() => {
      this.buttonTarget.textContent = "コピーしました！"
      setTimeout(() => {
        this.buttonTarget.textContent = "コピー"
      }, 2000)
    }).catch(() => {
      // Clipboard API非対応ブラウザへのフォールバック
      this.sourceTarget.select()
      document.execCommand('copy')
    })
  }
}