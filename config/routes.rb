Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resource :sign_in, only: [:new, :create, :destroy], controller: :sign_in
  resource :sign_up, only: [:new, :create],           controller: :sign_up

  get "/auth/verify_account/:token" => "auth#verify_account", as: :verify_account
  get "/auth/reset_password/:token" => "auth#reset_password", as: :reset_password
end
