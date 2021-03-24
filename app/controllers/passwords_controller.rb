class PasswordsController < ApplicationController
  def new
    render html: cell(Password::Cell::New, nil, layout: Layout::Cell::Authentication)
  end

  def create
  end

  def edit
    render html: cell(Password::Cell::Edit, nil, layout: Layout::Cell::Authentication)
  end

  def update
  end
end
