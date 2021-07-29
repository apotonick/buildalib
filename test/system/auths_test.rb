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

    # assert_emails 1 do
        click_on "Sign up"

        assert_selector "h2", text: "Welcome!"
    # end
    # check mail content

    # correct token
    verify_account_email = open_email("yogi@trb.to")
    assert_must have_body_text(/auth\/verify_account\/\w+/), verify_account_email
    assert_must deliver_to("yogi@trb.to"), verify_account_email
    click_first_link_in_email(verify_account_email)

# Verify account
    # wrong credentials
  end
end
