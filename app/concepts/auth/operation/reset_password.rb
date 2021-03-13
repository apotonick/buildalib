module Auth::Operation
  class ResetPassword < Trailblazer::Operation
    step :find_user
    pass :reset_password
    step :state
    step :save_user
    step :generate_verify_account_token
    step :save_verify_account_token
    step :send_verify_account_email

    def find_user(ctx, email:, **)
      ctx[:user] = User.find_by(email: email)
    end

    def reset_password(ctx, user:, **)
      user.password = nil
    end

    def state(ctx, user:, **)
      user.state = "password reset, please change password"
    end

    def save_user(ctx, user:, **)
      user.save
    end

    # FIXME: copied from CreateAccount!!!
    def generate_verify_account_token(ctx, secure_random: SecureRandom, **)
      ctx[:verify_account_token] = secure_random.urlsafe_base64(32)
    end

    # FIXME: almost copied from CreateAccount!!!
    def save_verify_account_token(ctx, verify_account_token:, user:, **)
      begin
        ResetPasswordKey.create(user_id: user.id, key: verify_account_token) # VerifyAccountKey => ResetPasswordKey
      rescue ActiveRecord::RecordNotUnique
        ctx[:error] = "Please try again."
        return false
      end
    end

    def send_verify_account_email(ctx, verify_account_token:, user:, **)
      token_path = "#{user.id}_#{verify_account_token}" # stolen from Rodauth.

      ctx[:verify_account_token] = token_path

      ctx[:email] = AuthMailer.with(email: user.email, reset_password_token: token_path).reset_password_email.deliver_now
    end
  end
end
