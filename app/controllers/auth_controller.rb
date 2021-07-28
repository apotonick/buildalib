class AuthController < ApplicationController
  include Trailblazer::Endpoint::Controller.module(dsl: true, application_controller: true)


  class Protocol < Trailblazer::Endpoint::Protocol
    def authenticate(*); true; end
    def policy(*); true; end
  end

  endpoint protocol: Protocol, adapter: Trailblazer::Endpoint::Adapter::Web
    # domain_ctx_filter: ApplicationController.current_user_in_domain_ctx

  endpoint Trailblazer::Operation # FIXME
  endpoint Auth::Operation::CreateAccount do
    {
      Output(:fail_fast) => Track(:failure)
    }
  end

  def signup_form
    # ctx = {}
    # render cell(Auth::SignUp::Cell::New, ctx, layout: Layout::Cell::Authentication)

    endpoint Trailblazer::Operation do |ctx|
      render cell(Auth::SignUp::Cell::New, ctx)
    end
  end

  # problem: {params[:signup]} could be nil
  #       passing all variables is cumbersome
  def signup
    endpoint Auth::Operation::CreateAccount, options_for_domain_ctx: {email: params[:signup][:email], password: params[:signup][:password], password_confirm: params[:signup][:password_confirm]} do |ctx|
      render cell(Auth::SignUp::Cell::Success, ctx)
    end.Or do |ctx|
      render cell(Auth::SignUp::Cell::New, ctx)
    end
  end

  # private def render(cell = nil, options = {}, *, &block)
  #   options = options.merge(layout: Layout::Cell::Authentication)
  #   # raise options.inspect
  #   # super(cell, options)

  #   content = cell.()

  #     super({html: content})
  # end
  def cell(cell_class, model, options={})
    super(cell_class, model, options.merge(layout: Layout::Cell::Authentication)) # FIXME: this interface sucks.
  end
  # include Trailblazer::Rails::Controller::Cell::Render
end
