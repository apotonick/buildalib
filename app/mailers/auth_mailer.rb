# https://guides.rubyonrails.org/action_mailer_basics.html#generating-urls-in-action-mailer-views
class AuthMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @email = params[:email]
    @verify_token = params[:verify_token]
    @url  = 'http://example.com/login'
    mail(to: @email, subject: 'Welcome to My Awesome Site')
  end

  def reset_password_email
    @email                = params[:email]
    @reset_password_token = params[:reset_password_token]
    mail(to: @email, subject: 'Please change your password')
  end
end
