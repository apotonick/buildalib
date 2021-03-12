require "test_helper"

class AuthOperationTest < Minitest::Spec
  describe "Auth::Operation::Create" do
    it "accepts valid email and passwords" do
      result = Auth::Operation::CreateAccount.wtf?(
        {
          email:            "yogi@trb.to",
          password:         "1234",
          password_confirm: "1234",
        }
      )

      assert result.success?
    end

    it "fails on invalid input" do
      result = Auth::Operation::CreateAccount.wtf?(
        {
          email:            "yogi@trb", # invalid email.
          password:         "1234",
          password_confirm: "1234",
        }
      )

      assert result.failure?
    end
  end # describe/Create

end
