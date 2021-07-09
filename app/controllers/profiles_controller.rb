class ProfilesController < ApplicationController
  def edit
    render html: cell(Profile::Cell::Edit, nil, layout: Layout::Cell::Authentication)
  end

  def update
  end
end
