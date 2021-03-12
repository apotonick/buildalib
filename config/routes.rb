Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get "/auth/verify_account/:token" => "auth#verify_account", as: :verify_account
end
