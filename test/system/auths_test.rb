require "application_system_test_case"

class AuthsTest < ApplicationSystemTestCase
  driven_by :selenium, using: :headless_chrome
  include ActionMailer::TestHelper

  test "visiting the index" do
    User.delete_all # FIXME

    visit signup_url

# Nothing filled in
    click_on "Sign up"
    assert_selector "h2", text: "Create your account"
    # assert_selector "#signup_email[value='']"
    # TODO: test callout bubble
    # TODO: test manual, empty POST

# Invalid email
    fill_in "Email", with: "yogi@trb"
    click_on "Sign up"
    assert_selector "h2", text: "Create your account"
    assert_selector ".error", text: "Email invalid."
    assert_selector "#signup_email[value='yogi@trb']"

# Invalid password
    fill_in "Email", with: "yogi@trb.to"
    click_on "Sign up"
    assert_selector "h2", text: "Create your account"
    assert_selector ".error", text: "Password does not meet requirements."
    assert_selector "#signup_email[value='yogi@trb.to']"

# Valid input
    fill_in "Email", with: "yogi@trb.to"
    fill_in "Password", with: "1234"
    fill_in "Confirm password", with: "1234"

    assert_emails 1 do
        click_on "Sign up"

        assert_selector "h2", text: "Welcome!"
    end
    # check mail content
    email = ActionMailer::Base.deliveries.last
    assert_equal ["yogi@trb.to"], email.to
    assert_match /auth\/verify_account\/\w+/, email.body.to_s
  end
end
