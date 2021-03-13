module Auth::Operation
  class Login < Trailblazer::Operation
    step :find_user
    step :password_hash_match?

    def find_user(ctx, email:, **) # TODO: redundant with VerifyAccount#find_user.
      ctx[:user] = User.find_by(email: email)
    end

    def password_hash_match?(ctx, user:, password:, **)
      BCrypt::Password.new(user.password) == password # stolen from Rodauth.
    end

    # You could add more login logic here, like logging log-in, logging failed attempt, and such.
  end
end
