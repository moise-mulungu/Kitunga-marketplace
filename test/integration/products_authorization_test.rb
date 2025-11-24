require "test_helper"
require "jwt"
require "securerandom"

class ProductsAuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    ENV["DEVISE_JWT_SECRET_KEY"] ||= "test_secret_key"
    @customer = User.create!(full_name: "Cust", email: "cust@example.com", password: "password", password_confirmation: "password", role: "customer", confirmed_at: Time.current)
    @seller = User.create!(full_name: "Seller", email: "seller@example.com", password: "password", password_confirmation: "password", role: "seller", confirmed_at: Time.current)
  end

  def jwt_for(user, exp = 1.hour.from_now)
    payload = { "sub" => user.id, "jti" => SecureRandom.uuid, "exp" => exp.to_i }
    JWT.encode(payload, ENV["DEVISE_JWT_SECRET_KEY"], "HS256")
  end

  test "customer cannot create product" do
    token = jwt_for(@customer)
    post "/api/v1/products", params: { product: { title: "X", description: "Y", price: 9.99, quantity: 10 } }, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :forbidden
  end

  test "seller can create product" do
    token = jwt_for(@seller)
    assert_difference "Product.count", 1 do
      post "/api/v1/products", params: { product: { title: "Seller Product", description: "Good", price: 19.99, quantity: 5 } }, headers: { "Authorization" => "Bearer #{token}" }
      assert_response :created
    end
  end
end
