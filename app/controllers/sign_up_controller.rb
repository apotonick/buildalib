class SignUpController < ApplicationController
  def new
    render html: cell(SignUp::Cell::New, nil, layout: Layout::Cell::Authentication)
  end

  def create
  end
end
