# frozen_string_literal: true

SimpleCov.start("rails") do
  add_group "Services", "app/services"
  add_group "Components", "app/components"
end
puts "loaded simplecov.."
