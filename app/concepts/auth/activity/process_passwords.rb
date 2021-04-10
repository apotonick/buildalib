module Auth::Activity
  # Check if both {:password} and {:password_confirm} are identical.
  # Then, hash the password.
  class ProcessPasswords < Trailblazer::Operation
    step :passwords_identical?
    fail :passwords_invalid_msg, fail_fast: true
    step :password_hash

    def passwords_identical?(ctx, password:, password_confirm:, **)
      password == password_confirm
    end

    def passwords_invalid_msg(ctx, **)
      ctx[:error] = "Passwords do not match."
    end

    def password_hash(ctx, password:, bcrypt_cost: BCrypt::Engine::MIN_COST, **) # stolen from Rodauth.
      ctx[:password_hash] = BCrypt::Password.create(password, cost: bcrypt_cost)
    end
  end
end
