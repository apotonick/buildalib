require "test_helper"

class AuthOperationTest < Minitest::Spec
  include ActionMailer::TestHelper

  describe "Auth::Operation::Create" do
    #@H
    it "validates input, encrypts the password, saves user,
          creates a verify-account token and send a welcome email" do
      result = nil
      assert_emails 1 do
        result = Auth::Operation::CreateAccount.wtf?(
          {
            email:            "yogi@trb.to",
            password:         "1234",
            password_confirm: "1234",
          }
        )
      end

      assert result.success?

      user = result[:user]
      assert user.persisted?
      assert_equal "yogi@trb.to", user.email
      assert_equal 60, user.password.size
      assert_equal "created, please verify account", user.state

      assert_match /#{user.id}_.+/, result[:verify_account_token]

      verify_account_key = VerifyAccountKey.where(user_id: user.id)[0]
      # key is something like "aJK1mzcc6adgGvcJq8rM_bkfHk9FTtjypD8x7RZOkDo"
      assert_equal 43, verify_account_key.key.size

      assert_match /\/auth\/verify_account\/#{user.id}_#{verify_account_key.key}/, result[:email].body.to_s
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

    class NotRandom
      def self.urlsafe_base64(*)
        "this is not random"
      end
    end

    it "fails when trying to insert the same {verify_account_token} twice" do
      options = {
        email:            "fred@trb.to",
        password:         "1234",
        password_confirm: "1234",
        secure_random:    NotRandom # inject a test dependency.
      }

      result = Auth::Operation::CreateAccount.wtf?(options)
      assert result.success?
      assert_equal "this is not random", result[:verify_account_key]

      result = Auth::Operation::CreateAccount.wtf?(options.merge(email: "celso@trb.to"))
      assert result.failure? # verify account token is not unique.
      assert_equal "Please try again.", result[:error]
    end
  end # describe/CreateAccount

  let(:valid_create_options) {
    {
      email:            "yogi@trb.to",
      password:         "1234",
      password_confirm: "1234",
    }
  }

  describe "VerifyAccount" do

    it "allows finding an account from {verify_account_token}" do
        result = Auth::Operation::CreateAccount.wtf?(valid_create_options)
        assert result.success?

        verify_account_token = result[:verify_account_token] # 158_NvMiR6UVglr4pXT_8dqIJB41c0o3lKul2RQc84Tn2kc

        result = Auth::Operation::VerifyAccount.wtf?(verify_account_token: verify_account_token)
        assert result.success?

        user = result[:user]
        assert_equal "ready to login", user.state
        assert_equal "yogi@trb.to", user.email
        assert_nil VerifyAccountKey.where(user_id: user.id)[0]
      end

      it "fails with invalid ID prefix" do
        result = Auth::Operation::VerifyAccount.wtf?(verify_account_token: "0_safasdfafsaf")
        assert result.failure?
      end

      it "fails with invalid token" do
        result = Auth::Operation::CreateAccount.wtf?(valid_create_options)
        assert result.success?

        result = Auth::Operation::VerifyAccount.wtf?(verify_account_token: result[:verify_account_token] + "rubbish")
        assert result.failure?

        result = Auth::Operation::VerifyAccount.wtf?(verify_account_token: "")
        assert result.failure?
      end

      it "fails second time" do
        result = Auth::Operation::CreateAccount.wtf?(valid_create_options)
        assert result.success?

        result = Auth::Operation::VerifyAccount.wtf?(verify_account_token: result[:verify_account_token])
        assert result.success?
        result = Auth::Operation::VerifyAccount.wtf?(verify_account_token: result[:verify_account_token])
        assert result.failure?
      end
  end # describe/VerifyAccount

  describe "#ResetPassword" do
    it "fails with unknown email" do
      result = Auth::Operation::ResetPassword.wtf?(
        {
          email:            "i_do_not_exist@trb.to",
        }
      )

      assert result.failure?
    end

    it "resets password and sends a reset-password email" do
      # test setup aka "factories":
      result = Auth::Operation::CreateAccount.wtf?(valid_create_options)
      result = Auth::Operation::VerifyAccount.wtf?(verify_account_token: result[:verify_account_token])

      assert_emails 1 do
        # the actual test.
        result = Auth::Operation::ResetPassword.wtf?(
          {
            email:            "yogi@trb.to",
          }
        )

        assert result.success?

        user = result[:user]
        assert user.persisted?
        assert_equal "yogi@trb.to", user.email
        assert_nil user.password                                  # password reset!
        assert_equal "password reset, please change password", user.state

        assert_match /#{user.id}_.+/, result[:reset_password_token]

        reset_password_key = ResetPasswordKey.where(user_id: user.id)[0]
        # key is something like "aJK1mzcc6adgGvcJq8rM_bkfHk9FTtjypD8x7RZOkDo"
        assert_equal 43, reset_password_key.key.size

        assert_match /\/auth\/reset_password\/#{user.id}_#{reset_password_key.key}/, result[:email].body.to_s
      end

    end

    it "fails when trying to insert the same {reset_password_token} twice" do
      result = Auth::Operation::CreateAccount.wtf?(valid_create_options)
      result = Auth::Operation::VerifyAccount.wtf?(verify_account_token: result[:verify_account_token])
      result = Auth::Operation::ResetPassword.wtf?(email: "yogi@trb.to", secure_random: NotRandom)
      assert_equal "this is not random", result[:key]

      result = Auth::Operation::CreateAccount.wtf?(valid_create_options.merge(email: "fred@trb.to"))
      result = Auth::Operation::VerifyAccount.wtf?(verify_account_token: result[:verify_account_token])
      result = Auth::Operation::ResetPassword.wtf?(email: "fred@trb.to", secure_random: NotRandom)
      assert result.failure? # verify account token is not unique.
      assert_equal "Please try again.", result[:error]
    end
  end # describe/ResetPassword

  describe "UpdatePassword::CheckToken" do
    it "finds user by reset-password token and compares keys" do
      # test setup aka "factories", we don't have to use `wtf?` every time.
      result = Auth::Operation::CreateAccount.(valid_create_options)
      result = Auth::Operation::VerifyAccount.(verify_account_token: result[:verify_account_token])
      result = Auth::Operation::ResetPassword.(email: "yogi@trb.to")
      token  = result[:reset_password_token]

      result = Auth::Operation::UpdatePassword::CheckToken.wtf?(token: token)
      assert result.success?

      original_key = result[:key] # note how you can read variables written in CheckToken if you don't use {:output}.

      user = result[:user]
      assert user.persisted?
      assert_equal "yogi@trb.to", user.email
      assert_nil user.password                                  # password reset!
      assert_equal "password reset, please change password", user.state

      # key is still in database:
      reset_password_key = ResetPasswordKey.where(user_id: user.id)[0]
      # key hasn't changed:
      assert_equal original_key, reset_password_key
    end

    it "fails with wrong token" do
      result = Auth::Operation::CreateAccount.(valid_create_options)
      result = Auth::Operation::VerifyAccount.(verify_account_token: result[:verify_account_token])
      result = Auth::Operation::ResetPassword.(email: "yogi@trb.to")
      token  = result[:reset_password_token]

      result = Auth::Operation::UpdatePassword::CheckToken.wtf?(token: token + "rubbish")
      assert result.failure?
    end
  end # describe/UpdatePassword::CheckToken

  describe "UpdatePassword" do
    it "finds user by reset_password_token and updates password" do
      result = Auth::Operation::CreateAccount.(valid_create_options)
      result = Auth::Operation::VerifyAccount.(verify_account_token: result[:verify_account_token])
      result = Auth::Operation::ResetPassword.(email: "yogi@trb.to")
      token  = result[:reset_password_token]

      result = Auth::Operation::UpdatePassword.wtf?(token: token, password: "12345678", password_confirm: "12345678")
      assert result.success?

      user = result[:user]
      assert user.persisted?
      assert_equal "yogi@trb.to", user.email
      assert_equal 60, user.password.size
      assert_equal "ready to login", user.state

      # key is expired:
      assert_nil ResetPasswordKey.where(user_id: user.id)[0]
    end

    it "fails with wrong password combo" do
      result = Auth::Operation::CreateAccount.(valid_create_options)
      result = Auth::Operation::VerifyAccount.(verify_account_token: result[:verify_account_token])
      result = Auth::Operation::ResetPassword.(email: "yogi@trb.to")
      token  = result[:reset_password_token]

      result = Auth::Operation::UpdatePassword.wtf?(
        token:            token,
        password:         "12345678",
        password_confirm: "123"
      )
      assert result.failure?
      assert_equal "Passwords do not match.", result[:error]
      assert_nil result[:user].password
    end
  end # describe/UpdatePassword

  describe "Login" do
    it "is successful with existing, active account" do
      result = Auth::Operation::CreateAccount.(valid_create_options)
      result = Auth::Operation::VerifyAccount.(verify_account_token: result[:verify_account_token])
      result = Auth::Operation::ResetPassword.(email: "yogi@trb.to")
      token  = result[:reset_password_token]
      result = Auth::Operation::UpdatePassword.(token: token, password: "12345678", password_confirm: "12345678")

      result = Auth::Operation::Login.wtf?(email: "yogi@trb.to", password: "12345678")
      assert result.success?

    # fails with wrong password
      result = Auth::Operation::Login.wtf?(email: "yogi@trb.to", password: "abcd")
      assert result.failure?
    end

    it "fails with unknown email" do
      result = Auth::Operation::Login.wtf?(email: "yogi@trb.to", password: "abcd")
      assert result.failure?
    end
  end # describe/Login
end
