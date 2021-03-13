module Auth
  module Activity
    class CreateKey < Trailblazer::Operation
      step :generate_key
      step :save_key

      def generate_key(ctx, secure_random: SecureRandom, **)
        ctx[:key] = secure_random.urlsafe_base64(32)
      end

      def save_key(ctx, key:, user:, key_model_class:, **)
        begin
          key_model_class.create(user_id: user.id, key: key) # key_model_class = VerifyAccountKey or ResetPasswordKey
        rescue ActiveRecord::RecordNotUnique
          ctx[:error] = "Please try again."
          return false
        end
      end
    end # CreateKey
  end
end
