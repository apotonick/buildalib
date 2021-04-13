module Auth::Activity
  # Check if both {:password} and {:password_confirm} are identical.
  # Then, hash the password.
  class ProcessPasswords < Trailblazer::Operation
    step :identical?
    fail :not_identical, fail_fast: true
    step :valid?
    fail :not_valid, fail_fast: true
    step :password_hash

    def identical?(ctx, password:, password_confirm:, **)
      password == password_confirm
    end

    def valid?(ctx, password:, **)
      password && password.size >= 4
    end

    def not_identical(ctx, **)
      ctx[:error] = "Passwords do not match."
    end

    def not_valid(ctx, **)
      ctx[:error] = "Password does not meet requirements."
    end

    def password_hash(ctx, password:, bcrypt_cost: BCrypt::Engine::MIN_COST, **) # stolen from Rodauth.
      ctx[:password_hash] = BCrypt::Password.create(password, cost: bcrypt_cost)
    end
  end
end
