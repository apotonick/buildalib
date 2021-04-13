require "test_helper"

# test/operations/utility_test.rb
class UtilityOperationTest < Minitest::Spec
  describe "ProcessPasswords" do
    it "allows +4, identical chars passwords" do
      options = {password: "1234", password_confirm: "1234"}
      result = Auth::Activity::ProcessPasswords.(options)
      assert result.success?
      assert_nil result[:error]
    end

    it "rejects not matching passwords" do
      options = {password: "1234", password_confirm: ""}
      result = Auth::Activity::ProcessPasswords.(options)
      assert result.failure?
      assert_equal "Passwords do not match.", result[:error]
    end

    it "rejects passwords too short" do
      options = {password: "123", password_confirm: "123"}
      result = Auth::Activity::ProcessPasswords.wtf?(options)
      assert result.failure?
      assert_equal "Password does not meet requirements.", result[:error]
    end
  end
end
