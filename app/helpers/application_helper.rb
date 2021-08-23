# frozen_string_literal: true

module ApplicationHelper
  def sidebar_nav_link_to(name, path)
    active = request.path == path ? "border-primary" : "border-base-200"
    classes = "#{active} block px-4 py-1 my-3 text-base transition duration-500 ease-in-out"
    classes = "#{classes} transform border-l-4 text-base-content focus:shadow-outline"
    classes = "#{classes} focus:outline-none hover:text-secondary"
    link_to(name, path, class: classes)
  end

  def tailwind_classes_for(flash_type)
    default_classes = "text-base-100 #{flash_type} flash bg-#{flash_type}"
    {
      notice: "text-base-100 notice flash bg-success",
      error: "text-base-100 alert flash bg-error",
    }.stringify_keys[flash_type.to_s] || default_classes
  end
end
