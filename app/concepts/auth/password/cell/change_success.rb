module Auth::Password
  module Cell
    class ChangeSuccess < Trailblazer::Cell
      # property :token
      def email
        model[:user].email
      end
    end
  end
end
