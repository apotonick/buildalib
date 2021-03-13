module Auth::Operation
  class UpdatePassword < Trailblazer::Operation
    class CheckToken < Auth::Activity::CheckToken
      private def key_model_class
        ResetPasswordKey
      end
    end

    step Subprocess(CheckToken)                       # provides {:user}
    step Subprocess(Auth::Activity::ProcessPasswords), # provides {:password_hash}
      fail_fast: true
    step :state
    step :update_user
    step :expire_reset_password_key

    def state(ctx, **)
      ctx[:state] = "ready to login"
    end

    def update_user(ctx, user:, password_hash:, state:, **)
      user.update_attributes(
        password: password_hash,
        state: state
      )
    end

    def expire_reset_password_key(ctx, key:, **)
      key.delete
    end
  end # UpdatePassword
end
