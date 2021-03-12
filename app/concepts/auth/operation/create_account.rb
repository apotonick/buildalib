module Auth::Operation
  class CreateAccount < Trailblazer::Operation
    step :check_email
    step :passwords_identical?

    def check_email(ctx, email:, **)
      email =~ /\A[^,;@ \r\n]+@[^,@; \r\n]+\.[^,@; \r\n]+\z/ # login_email_regexp, stolen from Rodauth.
    end

    def passwords_identical?(ctx, password:, password_confirm:, **)
      password == password_confirm
    end
  end
end
