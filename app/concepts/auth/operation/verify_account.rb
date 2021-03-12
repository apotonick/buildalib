module Auth::Operation
  class VerifyAccount < Trailblazer::Operation
    step :extract_from_token
    step :find_verify_account_token
    step :find_user
    step :compare_keys
    step :state # DISCUSS: move outside?
    step :save  # DISCUSS: move outside?
    step :expire_verify_account_token

    def extract_from_token(ctx, verify_account_token:, **)
      id, key = Auth::TokenUtils.split_token(verify_account_token)

      ctx[:id]  = id
      ctx[:key] = key # returns false if we don't have a key.
    end

    def find_verify_account_token(ctx, id:, **)
      ctx[:verify_account_key] = VerifyAccountKey.where(user_id: id)[0]
    end

    def find_user(ctx, id:, **)
      ctx[:user] = User.find_by(id: id)
    end

    def compare_keys(ctx, verify_account_key:, key:, **)
      Auth::TokenUtils.timing_safe_eql?(key, verify_account_key.key) # a hack-proof == comparison.
    end

    def state(ctx, user:, **)
      user.state = "ready to login"
    end

    def save(ctx, user:, **)
      user.save
    end

    def expire_verify_account_token(ctx, verify_account_key:, **)
      verify_account_key.delete
    end
  end
end
