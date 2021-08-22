import { Controller } from "stimulus";

export default class extends Controller {
  declare checkTarget: HTMLElement;
  declare checkTargets: HTMLElement[];
  declare hasCheckTarget: boolean;

  static targets = ["check"];

  connect() {
    this.checkTarget.classList.remove("text-error");
    this.checkTarget.classList.add("text-success");
    this.checkTarget.textContent =
      "- Your StimulusJS with Typescript setup is working.";
  }
}
