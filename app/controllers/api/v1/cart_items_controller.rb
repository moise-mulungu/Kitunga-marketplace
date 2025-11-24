module Api
  module V1
    class CartItemsController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :set_cart

      # POST /api/v1/cart_items
      # params: { cart_item: { product_id: integer, quantity: integer } }
      def create
        product = Product.find_by(id: cart_item_params[:product_id])
        return render json: { error: "Product not found" }, status: :not_found unless product
        qty = [ cart_item_params[:quantity].to_i, 1 ].max

        # STOCK CHECK
        if product.quantity.present? && qty > product.quantity
          return render json: { error: "Not enough stock" }, status: :unprocessable_entity
        end

        item = @cart.cart_items.find_by(product_id: product.id)

        ActiveRecord::Base.transaction do
          if item
            new_qty = item.quantity + qty
            if product.quantity.present? && new_qty > product.quantity
              return render json: { error: "Not enough stock for requested quantity" }, status: :unprocessable_entity
            end
            item.update!(quantity: new_qty)
          else
            item = @cart.cart_items.create!(
              product: product,
              quantity: qty,
              unit_price: product.price
            )
          end
          item.save! # ensure callbacks run
        end

        render json: @cart.as_json_with_items, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      # PUT /api/v1/cart_items/:id
      # params: { cart_item: { quantity: integer } }
      def update
        item = @cart.cart_items.find_by(id: params[:id])
        return render json: { error: "Cart item not found" }, status: :not_found unless item

        qty = cart_item_update_params[:quantity].to_i
        return render json: { error: "Invalid quantity" }, status: :unprocessable_entity if qty <= 0

        if item.product.quantity.present? && qty > item.product.quantity
          return render json: { error: "Not enough stock" }, status: :unprocessable_entity
        end

        item.update!(quantity: qty)
        render json: @cart.as_json_with_items, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      # DELETE /api/v1/cart_items/:id
      def destroy
        item = @cart.cart_items.find_by(id: params[:id])
        return render json: { error: "Cart item not found" }, status: :not_found unless item

        item.destroy
        render json: @cart.as_json_with_items, status: :ok
      end

      private

      def set_cart
        @cart = current_user.cart || current_user.create_cart
      end

      def cart_item_params
         params.permit(:product_id, :quantity)
      end

      def cart_item_update_params
        params.permit(:quantity)
      end
    end
  end
end
