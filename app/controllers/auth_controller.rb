class AuthController < ApplicationController
  def signup_form
    ctx = {}
    render html: cell(Auth::SignUp::Cell::New, ctx, layout: Layout::Cell::Authentication)
  end

  # problem: {params[:signup]} could be nil
  #       passing all variables is cumbersome
  def signup
    ctx = run Auth::Operation::CreateAccount, **{email: params[:signup][:email], password: params[:signup][:password], password_confirm: params[:signup][:password_confirm]} do |ctx|
      render cell(Auth::SignUp::Cell::Success, ctx, layout: Layout::Cell::Authentication)
      # return raise("thanks!")
    end

    render cell(Auth::SignUp::Cell::New, ctx, layout: Layout::Cell::Authentication)
  end
end
