import { Controller } from "stimulus";

function withPasswordFields(callback: (el: Element) => void) {
  document.querySelectorAll(".auth-password").forEach((el) => callback(el));
}
export default class extends Controller {
  declare togglerTarget: HTMLElement;

  declare authButtonTarget: HTMLElement;

  declare passwordAreaTarget: HTMLElement;

  static targets = ["toggler", "passwordArea", "authButton"];

  connect() {
    const name = this.togglerTarget.dataset.magicName;

    this.authButtonTarget.setAttribute("value", name);
    this.authButtonTarget.setAttribute("data-disable-with", name);
    withPasswordFields((el) => el.classList.add("hidden"));
  }

  togglePasswordArea() {
    const name = this.togglerTarget.dataset.authName;

    this.togglerTarget.remove();
    this.authButtonTarget.setAttribute("value", name);
    this.authButtonTarget.setAttribute("data-disable-with", name);
    withPasswordFields((el) => el.classList.remove("hidden"));

    (this.element as HTMLElement).removeAttribute("data-controller");
  }
}
