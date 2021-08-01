class AuthController < ApplicationController
  include Trailblazer::Endpoint::Controller.module(dsl: true, application_controller: true)

  class Protocol < Trailblazer::Endpoint::Protocol
    def authenticate(*); true; end
    def policy(*); true; end
  end

  def self.options_for_block_options(ctx, **)
    {
      invoke: Trailblazer::Developer.method(:wtf?) # FIXME
    }
  end


  # def self.options_for_endpoint(ctx, controller:, **)
  #   {
  #     cipher_key: Rails.application.config.cipher_key,

  #     encrypted_resume_data: controller.params[:encrypted_resume_data],
  #   }
  # end

  directive :options_for_block_options, method(:options_for_block_options)

  endpoint protocol: Protocol, adapter: Trailblazer::Endpoint::Adapter::Web
    # domain_ctx_filter: ApplicationController.current_user_in_domain_ctx

  endpoint Trailblazer::Operation # FIXME: render-only actions, can we exclude them from the `#send_action` override?
  endpoint Auth::Operation::CreateAccount do
    {
      Output(:fail_fast) => Track(:failure)
    }
  end
  endpoint Auth::Operation::VerifyAccount
  endpoint Auth::Operation::ResetPassword

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

  def verify_account
    endpoint Auth::Operation::VerifyAccount, options_for_domain_ctx: {verify_account_token: params[:token]} do |ctx|
      render cell(Auth::SignUp::Cell::VerifySuccess, ctx[:user])
    end.Or do |ctx|
      render cell(Auth::SignUp::Cell::VerifyFailure, ctx) # TODO: offer link for fresh token?
    end
  end

  def forgot_password_form
    endpoint Trailblazer::Operation do |ctx|      # FIXME/DISCUSS
      render cell(Auth::Password::Cell::ResetForm, ctx)# OpenStruct.new(email: nil))
    end
  end

  def cell(cell_class, model, options={})
    super(cell_class, model, options.merge(layout: Layout::Cell::Authentication)) # FIXME: this interface sucks.
  end
  # include Trailblazer::Rails::Controller::Cell::Render
end
