import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]

  toggle() {
    this.panelTarget?.classList.toggle("is-open")
    this.backdropTarget?.classList.toggle("is-open")
  }

  close() {
    this.panelTarget?.classList.remove("is-open")
    this.backdropTarget?.classList.remove("is-open")
  }
}
