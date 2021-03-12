module Auth::Activity
  # Splits token, finds user and key row by {:token}, and compares safely.
  class CheckToken < Trailblazer::Operation
    step :extract_from_token
    step :find_key
    step :find_user
    step :compare_keys

    def extract_from_token(ctx, token:, **)
      id, key = Auth::TokenUtils.split_token(token)

      ctx[:id]  = id
      ctx[:input_key] = key # returns false if we don't have a key.
    end

    def find_key(ctx, id:, **)
      ctx[:key] = key_model_class.where(user_id: id)[0]
    end

    def find_user(ctx, id:, **) # DISCUSS: might get moved outside.
      ctx[:user] = User.find_by(id: id)
    end

    def compare_keys(ctx, input_key:, key:, **)
      Auth::TokenUtils.timing_safe_eql?(input_key, key.token) # a hack-proof == comparison.
    end

    private def key_model_class
      raise "implement me"
    end
  end # CheckToken
end
