class SignInController < ApplicationController
  def new
    render html: cell(SignIn::Cell::New, nil, layout: Layout::Cell::Authentication)
  end

  def create
  end

  def destroy
  end
end
