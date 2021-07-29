module Auth::SignUp
  module Cell
    class VerifySuccess < Trailblazer::Cell
      # property :email
      def email
        model.email
      end
    end
  end
end
