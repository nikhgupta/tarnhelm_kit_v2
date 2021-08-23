// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js or *_controller.ts.

import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

const application = Application.start();

const context = require.context("controllers", true, /_controller\.(js|ts)$/);
application.load(definitionsFromContext(context));

const componentContext = require.context(
  "../../components",
  true,
  /_controller\.(js|ts)$/
);
application.load(definitionsFromContext(componentContext));

// Import and register all TailwindCSS Components
import {
  // Autosave,
  Dropdown,
  // Modal,
  // Tabs,
  // Popover,
  // Toggle,
  // Slideover,
} from "tailwindcss-stimulus-components";

// application.register("autosave", Autosave);
application.register("dropdown", Dropdown);
// application.register("modal", Modal);
// application.register("tabs", Tabs);
// application.register("popover", Popover);
// application.register("toggle", Toggle);
// application.register("slideover", Slideover);
