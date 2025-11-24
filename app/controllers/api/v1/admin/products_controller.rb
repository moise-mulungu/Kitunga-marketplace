module Api
  module V1
    module Admin
      class ProductsController < Api::V1::BaseController
        before_action :authenticate_user!
        before_action :require_admin!

        # PUT /api/v1/admin/products/:id/transfer
        # Accepts { owner_id: <user id> }
        def transfer
          product = Product.find(params[:id])
          if protect_owner?(product.user)
            return render json: { error: "Cannot transfer product owned by owner admin" }, status: :forbidden
          end

          owner_id = params[:owner_id] || params[:ownerId]
          target = User.find(owner_id)

          # Restrict transfer targets to sellers only
          unless target.seller?
            return render json: { error: "Target must be a seller" }, status: :unprocessable_entity
          end

          previous_owner_id = product.user_id
          product.user = target
          if product.save
            # Record admin action for audit
            begin
              AdminActionLog.create!(admin_id: current_user.id, action: "transfer_product", details: { product_id: product.id, from: previous_owner_id, to: target.id }.to_json)
            rescue => _e
              Rails.logger.warn("Failed to record admin action: #{_e.message}")
            end

            render json: { success: true, product: product }, status: :ok
          else
            render json: { error: product.errors.full_messages }, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Not found" }, status: :not_found
        end

        private

        def protect_owner?(user)
          user && user.email.present? && user.email.downcase == "moisemlg90@gmail.com"
        end
      end
    end
  end
end
