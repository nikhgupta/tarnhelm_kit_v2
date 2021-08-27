# frozen_string_literal: true

# For details on the DSL available within this file, see
# https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  devise_for :users,
    path_names: {
      sign_in: "login", sign_out: "logout", sign_up: "register",
    }, controllers: {
      passwords: "users/passwords",
      invitations: "users/invitations",
      confirmations: "users/confirmations",
      registrations: "users/registrations",
      sessions: "devise/passwordless/sessions",
      omniauth_callbacks: "users/omniauth_callbacks",
    }

  devise_scope :user do
    get "/users/magic_link", to: "devise/passwordless/magic_links#show", as: :users_magic_link
    get "/users/add/password", to: "users/passwords#add_password_to_magic_account", as: :add_magic_user_password

    authenticate :user do
      get "/users/edit/password", to: "devise/registrations#edit_password", as: :user_change_password
      get "/users/delete/data", to: "devise/registrations#delete_data", as: :user_delete_data
    end
  end

  mount Flipper::UI.app(Flipper) => "/admin/flipper", as: :feature_management

  authenticate :user, ->(user) { user.enabled?(:user_accounts) } do
    resources :accounts, except: [:edit, :update, :destroy] do
      member do
        post :switch
      end
    end
  end
  resources :authenticating_identities, path: :authentications, only: [:index, :destroy]

  get "/pages/:id", to: "pages#show", as: :pages
  root to: "pages#show", id: :home
end
