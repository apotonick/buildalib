module Auth::Operation
  class CreateAccount < Trailblazer::Operation
    step :check_email
    fail :email_invalid_msg, fail_fast: true
    step :passwords_identical?
    fail :passwords_invalid_msg, fail_fast: true
    step :password_hash
    step :state
    step :save_account
    step :generate_verify_account_key
    step :save_verify_account_key
    step :send_verify_account_email

    #~meth
    def check_email(ctx, email:, **)
      email =~ /\A[^,;@ \r\n]+@[^,@; \r\n]+\.[^,@; \r\n]+\z/
    end

    def passwords_identical?(ctx, password:, password_confirm:, **)
      password == password_confirm
    end

    def email_invalid_msg(ctx, **)
      ctx[:error] = "Email invalid."
    end

    def passwords_invalid_msg(ctx, **)
      ctx[:error] = "Passwords do not match."
    end
    def password_hash(ctx, password:, password_hash_cost: BCrypt::Engine::MIN_COST, **) # stolen from Rodauth.
      ctx[:password_hash] = BCrypt::Password.create(password, cost: password_hash_cost)
    end
    def state(ctx, **)
      ctx[:state] = "created, please verify account"
    end

    def save_account(ctx, email:, password_hash:, state:, **)
      begin
        user = User.create(email: email, password: password_hash, state: state)
      rescue ActiveRecord::RecordNotUnique
        ctx[:error] = "Email #{email} is already taken."
        return false
      end

      ctx[:user] = user
    end
    def generate_verify_account_key(ctx, secure_random: SecureRandom, **)
      ctx[:verify_account_key] = secure_random.urlsafe_base64(32)
    end

    def save_verify_account_key(ctx, verify_account_key:, user:, **)
      begin
        VerifyAccountKey.create(user_id: user.id, key: verify_account_key)
      rescue ActiveRecord::RecordNotUnique
        ctx[:error] = "Please try again."
        return false
      end
    end
    #~meth end

    def send_verify_account_email(ctx, verify_account_key:, user:, **)
      token = "#{user.id}_#{verify_account_key}" # stolen from Rodauth.

      ctx[:verify_account_token] = token

      ctx[:email] = AuthMailer.with(email: user.email, verify_token: token).welcome_email.deliver_now
    end
  end
end
