class HomeController < ApplicationController
  # include Trailblazer::Endpoint::Controller.module(dsl: true, application_controller: true)

  def dashboard
    render html: "yo"
  end
end
