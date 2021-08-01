require "application_system_test_case"
require "minitest-matchers"
require "email_spec"

class AuthsTest < ApplicationSystemTestCase
  driven_by :selenium, using: :headless_chrome
  # include ActionMailer::TestHelper
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  test "creating account" do
    User.delete_all # FIXME

    visit signup_form_url

# assert layout
    # puts page.body
    assert_selector ".content"

# [OP] sign up
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

    click_on "Sign up"

    assert_selector "h2", text: "Welcome!"

    # check mail content
    verify_account_email = open_email("yogi@trb.to")
    assert_must have_body_text(/auth\/verify_account\/\w+/), verify_account_email
    assert_must deliver_to("yogi@trb.to"), verify_account_email


# [OP] Verify account
    # wrong credentials
    url_with_token = links_in_email(verify_account_email)[0]
    path_with_token = url_with_token.sub("http://example.com", "")
    visit path_with_token+"rubbish"

    assert_selector "p", text: "Your token is invalid"

    # correct token
    click_first_link_in_email(verify_account_email)
    assert_selector "h2", text: "Success"
    assert_selector "p", text: "please sign in"
    assert_selector "p", text: "for yogi@trb.to"

# [OP] Reset password
    visit forgot_password_form_path

  # invalid request

  # successful request
    assert_selector "h2", text: "Reset your password"
    fill_in "Email", with: "yogi@trb.to"
  end
end
