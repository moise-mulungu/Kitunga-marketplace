require "test_helper"

class AdminProductsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin) # fixture should exist
    @seller1 = users(:seller) # fixture
    @seller2 = users(:seller2) # add a second seller fixture
  end

  test "admin can transfer product ownership" do
    # create product owned by seller1 (direct model creation)
    product = @seller1.products.create!(title: "Transferable", description: "X", price: 5.0, quantity: 2)

    # sign in as admin and transfer
    post "/api/v1/users/sign_in", params: { email: @admin.email, password: "password" }
    token = JSON.parse(response.body)["token"]

    put "/api/v1/admin/products/#{product.id}/transfer", params: { owner_id: @seller2.id }, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal @seller2.id, body["product"]["user_id"]
  end

  test "cannot transfer product owned by owner admin" do
    # sign in admin
    post "/api/v1/users/sign_in", params: { email: @admin.email, password: "password" }
    token = JSON.parse(response.body)["token"]

    # create a product owned by the protected owner user (fixture email must match)
    owner_user = User.create!(email: "moisemlg90@gmail.com", password: "password", role: "seller")
    product = owner_user.products.create!(title: "Owned by owner", description: "x", price: 1.0, quantity: 1)

    put "/api/v1/admin/products/#{product.id}/transfer", params: { owner_id: @seller1.id }, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :forbidden
  end
end
