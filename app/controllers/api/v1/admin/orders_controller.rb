module Api
  module V1
    module Admin
      class OrdersController < Api::V1::BaseController
        before_action :authenticate_user!
        before_action :require_admin!

        def index
          orders = Order.all.includes(:user, :order_items, :payment)
          render json: orders
        end

        def show
          order = Order.find(params[:id])
          render json: order, include: [:user, :order_items, :payment]
        end
      end
    end
  end
end