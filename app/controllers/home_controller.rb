class HomeController < ApplicationController
  include Trailblazer::Endpoint::Controller.module(dsl: true, application_controller: true)

  class Protocol < Trailblazer::Endpoint::Protocol
    def authenticate(ctx, controller:, **)
      user_id = controller.session[:current_user_id] or return # DISCUSS: separate OP?
      ctx[:current_user] = User.find_by(id: user_id) # will return false otherwise
    end

    def policy(*); true; end

    Trailblazer::Endpoint::Protocol::Controller.insert_copy_to_domain_ctx!(self, {current_user: :current_user})
  end

  def self.options_for_block_options(ctx, controller:, **)
    {
      invoke: Trailblazer::Developer.method(:wtf?), # FIXME
      protocol_failure_block: ->(ctx, **) { controller.render(controller.cell(Auth::Cell::NotAuthenticated, ctx)) }
    }
  end

  directive :options_for_block_options, method(:options_for_block_options)

  endpoint protocol: Protocol, adapter: Trailblazer::Endpoint::Adapter::Web

  endpoint Trailblazer::Operation # FIXME: render-only actions, can we exclude them from the `#send_action` override?

  def dashboard
    endpoint Trailblazer::Operation do |ctx, current_user:, **|
      render cell(Home::Cell::Dashboard, current_user)
    end
  end

  def cell(cell_class, model, options={})
    super(cell_class, model, options.merge(layout: Layout::Cell::Authentication)) # FIXME: this interface sucks.
  end # FIXME
end
