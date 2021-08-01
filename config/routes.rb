Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resource :sign_in, only: [:new, :create, :destroy], controller: :sign_in

  resource :profile, only: [:edit, :update]

  get  "/auth/signup" => "auth#signup_form",  as: :signup_form
  post "/auth/signup" => "auth#signup",       as: :signup
  get "/auth/signin"  => "auth#signin_form",  as: :signin_form

  get "/auth/forgot_password"  => "auth#forgot_password_form",  as: :forgot_password_form
  post "/auth/reset_password"  => "auth#reset_password",  as: :reset_password

  get "/auth/verify_account/:token" => "auth#verify_account", as: :verify_account
  # get "/auth/reset_password/:token" => "auth#reset_password", as: :reset_password
end
