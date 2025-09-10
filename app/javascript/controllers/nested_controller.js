import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "addButton", "warning"]

  connect() { console.log("nested connected") }  // ← デバッグ

  add(e) {
    e.preventDefault()
    const template = this.templateTarget.innerHTML
    const uid = Date.now().toString()
    // NEW_XXX というプレースホルダをユニークIDに置換
    const html = template.replace(/NEW_[A-Z_]+/g, uid)
    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(e) {
    e.preventDefault()
    const item = e.currentTarget.closest("[data-nested-item]")
    const destroyField = item.querySelector('input[name$="[_destroy]"]')
    if (destroyField) {
      // 既存レコード: _destroy = 1 にして非表示
      destroyField.value = "1"
      item.style.display = "none"
    } else {
      // 新規行: DOMから削除
      item.remove()
    }
  }
}