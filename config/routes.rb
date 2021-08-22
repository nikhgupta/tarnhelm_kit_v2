# frozen_string_literal: true

# For details on the DSL available within this file, see
# https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  mount Flipper::UI.app(Flipper) => "/admin/flipper", as: :feature_management
end
