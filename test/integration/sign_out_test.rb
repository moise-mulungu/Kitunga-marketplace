require 'test_helper'
require 'jwt'
require 'securerandom'

class SignOutTest < ActionDispatch::IntegrationTest
  setup do
    ENV['DEVISE_JWT_SECRET_KEY'] ||= 'test_secret_key'
    @user = User.create!(
      full_name: 'Signout User',
      email: 'signout_test@example.com',
      password: 'password',
      password_confirmation: 'password',
      role: 'customer',
      confirmed_at: Time.current
    )
  end

  def jwt_for(payload)
    JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
  end

  test 'sign_out revokes token and prevents refresh' do
    payload = { 'sub' => @user.id, 'jti' => SecureRandom.uuid, 'exp' => (Time.now + 1.hour).to_i }
    token = jwt_for(payload)

    delete '/api/v1/users/sign_out', headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :no_content

    # denylist should contain the jti
    assert JwtDenylist.exists?(jti: payload['jti'])

    # subsequent refresh should be rejected
    post '/api/v1/users/refresh', headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal 'Token revoked', json['error']
  end
end
