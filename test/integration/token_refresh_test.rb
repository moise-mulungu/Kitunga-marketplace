require "test_helper"
require "jwt"
require "securerandom"

class TokenRefreshTest < ActionDispatch::IntegrationTest
  setup do
    ENV["DEVISE_JWT_SECRET_KEY"] ||= "test_secret_key"
    @user = User.create!(
      full_name: "Test User",
      email: "refresh_test@example.com",
      password: "password",
      password_confirmation: "password",
      role: "customer",
      confirmed_at: Time.current
    )
  end

  def jwt_for(payload)
    JWT.encode(payload, ENV["DEVISE_JWT_SECRET_KEY"], "HS256")
  end

  test "refresh valid unexpired token" do
    payload = { "sub" => @user.id, "jti" => SecureRandom.uuid, "exp" => (Time.now + 1.hour).to_i }
    token = jwt_for(payload)

    post "/api/v1/users/refresh", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    json = JSON.parse(response.body)
    assert json["token"].present?
    assert_not_equal token, json["token"]
  end

  test "refresh expired within window" do
    payload = { "sub" => @user.id, "jti" => SecureRandom.uuid, "exp" => (Time.now - 2.days).to_i }
    token = jwt_for(payload)

    post "/api/v1/users/refresh", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    json = JSON.parse(response.body)
    assert json["token"].present?
  end

  test "reject expired beyond window" do
    payload = { "sub" => @user.id, "jti" => SecureRandom.uuid, "exp" => (Time.now - 10.days).to_i }
    token = jwt_for(payload)

    post "/api/v1/users/refresh", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "Refresh window expired", json["error"]
  end

  test "reject revoked token" do
    payload = { "sub" => @user.id, "jti" => SecureRandom.uuid, "exp" => (Time.now + 1.hour).to_i }
    token = jwt_for(payload)
    JwtDenylist.create!(jti: payload["jti"], exp: Time.at(payload["exp"]))

    post "/api/v1/users/refresh", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "Token revoked", json["error"]
  end
end
