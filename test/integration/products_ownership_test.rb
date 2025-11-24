require "test_helper"
require "jwt"
require "securerandom"

class ProductsOwnershipTest < ActionDispatch::IntegrationTest
  setup do
    ENV["DEVISE_JWT_SECRET_KEY"] ||= "test_secret_key"
    @seller = User.create!(
      full_name: "Seller",
      email: "seller@example.com",
      password: "password",
      password_confirmation: "password",
      role: "seller",
      confirmed_at: Time.current
    )

    @other_seller = User.create!(
      full_name: "Other Seller",
      email: "other_seller@example.com",
      password: "password",
      password_confirmation: "password",
      role: "seller",
      confirmed_at: Time.current
    )

    @customer = User.create!(
      full_name: "Customer",
      email: "customer@example.com",
      password: "password",
      password_confirmation: "password",
      role: "customer",
      confirmed_at: Time.current
    )

    @admin = User.create!(
      full_name: "Admin",
      email: "admin_products@example.com",
      password: "password",
      password_confirmation: "password",
      role: "admin",
      confirmed_at: Time.current
    )

    @product = Product.create!(
      title: "Owned Product",
      description: "An item",
      price: 10.0,
      quantity: 5,
      user: @seller
    )
  end

  def jwt_for(user)
    # Use the real sign-in endpoint to obtain a properly-dispatched JWT
    post "/api/v1/users/sign_in", params: { user: { email: user.email, password: "password" } }
    assert_response :success
    JSON.parse(response.body)["token"]
  end

  test "seller can update own product" do
    token = jwt_for(@seller)
    put "/api/v1/products/#{@product.id}", params: { product: { title: "Updated" } }, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    @product.reload
    assert_equal "Updated", @product.title
  end

  test "seller cannot update another sellers product" do
    token = jwt_for(@other_seller)
    put "/api/v1/products/#{@product.id}", params: { product: { title: "Bad Update" } }, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :forbidden
  end

  test "customer cannot update product" do
    token = jwt_for(@customer)
    put "/api/v1/products/#{@product.id}", params: { product: { title: "Bad Update" } }, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :forbidden
  end

  test "admin can update any product" do
    token = jwt_for(@admin)
    put "/api/v1/products/#{@product.id}", params: { product: { title: "Admin Update" } }, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    @product.reload
    assert_equal "Admin Update", @product.title
  end

  test "only owner or admin can delete" do
    # non-owner seller cannot delete
    token = jwt_for(@other_seller)
    delete "/api/v1/products/#{@product.id}", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :forbidden

    # owner can delete
    token = jwt_for(@seller)
    delete "/api/v1/products/#{@product.id}", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :no_content
  end
end
