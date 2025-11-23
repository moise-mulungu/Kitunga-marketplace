module Api
  module V1
    class CartsController < Api::V1::BaseController
      before_action :authenticate_user!

      # GET /api/v1/cart
      def show
        cart = find_or_create_cart_for(current_user)
        render json: cart.as_json_with_items, status: :ok
      end

      # DELETE /api/v1/cart
      # Clears the cart (removes all items)
      def destroy
        cart = find_or_create_cart_for(current_user)
        cart.cart_items.destroy_all
        render json: { message: "Cart cleared", cart_id: cart.id }, status: :ok
      end

      private

      def find_or_create_cart_for(user)
        user_cart = Cart.find_by(user_id: user.id)
        return user_cart if user_cart.present?

        Cart.create!(user: user)
      end
    end
  end
end
