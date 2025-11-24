require "test_helper"
require "jwt"

class ConfirmAndPasswordTest < ActionDispatch::IntegrationTest
  setup do
    ENV["DEVISE_JWT_SECRET_KEY"] ||= "test_secret_key"
    ActionMailer::Base.deliveries.clear
  end

  test "user confirmation flow" do
    ActionMailer::Base.deliveries.clear

    post "/api/v1/users", params: { user: { full_name: "Confirm User", email: "confirm_test@example.com", password: "password", password_confirmation: "password", role: "customer" } }
    assert_response :created

    mail = ActionMailer::Base.deliveries.last
    assert mail, "Confirmation email not sent"

    body = mail.body.encoded
    token = body.match(/confirmation_token=([^"\s&]+)/)&.captures&.first
    assert token, "Could not find confirmation token in email body"

    get "/api/v1/users/confirmation", params: { confirmation_token: token }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Account confirmed.", json["message"]

    user = User.find_by(email: "confirm_test@example.com")
    assert user.confirmed?
  end

  test "password reset flow" do
    user = User.create!(full_name: "Reset User", email: "reset_test@example.com", password: "oldpass", password_confirmation: "oldpass", confirmed_at: Time.current)

    ActionMailer::Base.deliveries.clear
    post "/api/v1/users/password", params: { user: { email: user.email } }
    assert_response :success

    mail = ActionMailer::Base.deliveries.last
    assert mail, "Reset password email not sent"

    body = mail.body.encoded
    token = body.match(/reset_password_token=([^"\s&]+)/)&.captures&.first
    assert token, "Could not find reset token in email body"

    put "/api/v1/users/password", params: { user: { reset_password_token: token, password: "newpass", password_confirmation: "newpass" } }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Password has been changed successfully.", json["message"]

    user.reload
    assert user.valid_password?("newpass")
  end
end
