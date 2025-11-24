require "test_helper"
require "jwt"
require "securerandom"

class AdminUsersTest < ActionDispatch::IntegrationTest
  setup do
    ENV["DEVISE_JWT_SECRET_KEY"] ||= "test_secret_key"
    @admin = User.create!(
      full_name: "Admin User",
      email: "admin@example.com",
      password: "password",
      password_confirmation: "password",
      role: "admin",
      confirmed_at: Time.current
    )

    @user = User.create!(
      full_name: "Normal User",
      email: "user@example.com",
      password: "password",
      password_confirmation: "password",
      role: "customer",
      confirmed_at: Time.current
    )
  end

  def jwt_for(payload)
    # prefer real sign-in to get a valid Devise-issued JWT
    user = User.find(payload["sub"])
    post "/api/v1/users/sign_in", params: { user: { email: user.email, password: "password" } }
    assert_response :success
    JSON.parse(response.body)["token"]
  end

  test "admin can list users" do
    payload = { "sub" => @admin.id, "jti" => SecureRandom.uuid, "exp" => (Time.now + 1.hour).to_i }
    token = jwt_for(payload)

    get "/api/v1/admin/users", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    assert json.any? { |u| u["email"] == "user@example.com" }
  end

  test "non-admin cannot list users" do
    payload = { "sub" => @user.id, "jti" => SecureRandom.uuid, "exp" => (Time.now + 1.hour).to_i }
    token = jwt_for(payload)

    get "/api/v1/admin/users", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :forbidden
  end

  test "admin can deactivate user" do
    payload = { "sub" => @admin.id, "jti" => SecureRandom.uuid, "exp" => (Time.now + 1.hour).to_i }
    token = jwt_for(payload)

    put "/api/v1/admin/users/#{@user.id}/deactivate", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    @user.reload
    assert_equal false, @user.active
  end

  test "admin can reactivate user" do
    # first deactivate
    payload = { "sub" => @admin.id, "jti" => SecureRandom.uuid, "exp" => (Time.now + 1.hour).to_i }
    token = jwt_for(payload)
    put "/api/v1/admin/users/#{@user.id}/deactivate", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    @user.reload
    assert_equal false, @user.active

    # now reactivate
    put "/api/v1/admin/users/#{@user.id}/reactivate", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    @user.reload
    assert_equal true, @user.active
  end

  test "admin can change user role" do
    payload = { "sub" => @admin.id, "jti" => SecureRandom.uuid, "exp" => (Time.now + 1.hour).to_i }
    token = jwt_for(payload)

    patch "/api/v1/admin/users/#{@user.id}/update", params: { role: "seller" }, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    @user.reload
    assert_equal "seller", @user.role
  end
end
