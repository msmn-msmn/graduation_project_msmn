import { Application } from "@hotwired/stimulus"
export const application = Application.start()
window.Stimulus = application     // ← デバッグ用（任意）
application.debug = true          // ← 任意（開発中）