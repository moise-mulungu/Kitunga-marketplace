class Api::V1::CheckoutsController < Api::V1::BaseController
  before_action :authenticate_user!

  def create
    cart = current_user.cart

    return render json: { error: "Cart is empty" }, status: :unprocessable_entity if cart.nil? || cart.cart_items.empty?

    ActiveRecord::Base.transaction do
      # 1. Create order
      order = Order.create!(
        user: current_user,
        status: :pending,
        payment_status: :unpaid
      )

      # 2. Convert cart_items → order_items
      cart.cart_items.includes(:product).each do |item|
        OrderItem.create!(
          order: order,
          product: item.product,
          quantity: item.quantity,
          price: item.unit_price,
          subtotal: item.subtotal
        )
      end

      # 3. Order callback automatically calculates total_amount
      order.save!

      # 4. Clear cart
      cart.cart_items.destroy_all

      render json: {
        message: "Order created successfully",
        order: order.as_json(
          include: {
            order_items: {
              include: { product: { only: [ :title, :price ] } }
            }
          }
        )
      }, status: :created
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
