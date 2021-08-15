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

    visit forgot_password_form_path

# [OP] Forgot password form
  # invalid request (---)
  # successful request
    assert_selector "h2", text: "Reset your password"

# [OP] Reset password

  # successful
    fill_in "Email", with: "yogi@trb.to"
    click_on "Send password reset email"

    assert_selector "h2", text: "Check your inbox!"

    reset_password_email = open_last_email()#[1]
    assert_must have_body_text(/auth\/change_password\?token=\w+/), reset_password_email
    assert_must deliver_to("yogi@trb.to"), reset_password_email

  # invalid (email doesn't exist)
   # TODO: separate block?
    visit forgot_password_form_path
    fill_in "Email", with: "yogi@trrrrrrrrb.to"
    click_on "Send password reset email"

    assert_selector "h2", text: "Check your inbox!"
    # TODO: assert emails haven't changed (we only assert what the user sees)
    new_reset_password_email = open_last_email # this is for "yogi@trrrrrrrrb.to"
    assert_equal reset_password_email, new_reset_password_email # nothing got sent

# [OP] UpdatePassword::CheckToken
  # wrong token
    url_with_token = links_in_email(reset_password_email)[0]
    path_with_token = url_with_token.sub("http://example.com", "")

    visit path_with_token+"rubbish" # TODO: this is /reset_password, should it be change_password?
    assert_selector "p", text: "Your token is invalid"

  # correct token
    visit path_with_token

    assert_selector "h2", text: "Change password"
    # puts page.body
    # make sure the token is embedded in a hidden field
    hidden_field = page.find("input[type='hidden']", visible: false)
    assert_equal 47, hidden_field.value.size
    # assert_selector "input[name='token',value='sdf']"

# [OP] UpdatePassword
  # incorrect passwords
    fill_in "Password", with: "1234"
    fill_in "Confirm password", with: "12345"
    click_on "Change password"

    assert_selector "h2", text: "Change password"
    assert_selector ".error", text: "Passwords do not match."
    assert_selector "input[name='password[password]']", text: ""
    assert_selector "input[name='password[password_confirm]']", text: "" # TODO: add text here?

  # correct submit
    fill_in "Password", with: "12345678"
    fill_in "Confirm password", with: "12345678"
    click_on "Change password"

    assert_selector "h2", text: "Password updated"
    assert_selector "p", text: "password for yogi@trb.to"

# [OP] Login
    click_on "sign in"

  # invalid password
    fill_in "Email", with: "yogi@trb.to"
    fill_in "Password", with: "12"
    click_on "Sign in"

    # the email is still provided in the input field
    assert_selector "input#signin_email[value='yogi@trb.to']"
    assert_selector "input#signin_password", text: ""

  # valid input
    fill_in "Email", with: "yogi@trb.to"
    fill_in "Password", with: "12345678"
    click_on "Sign in"

    # TODO: check for user id in cookie?
# [OP] dashboard

    # check for layout
    assert_selector ".content"


  end

  test "authenticate test" do
    visit dashboard_path
    assert_selector "h2", text: "Not authenticated"
  end
end
