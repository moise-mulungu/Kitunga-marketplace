class Api::V1::Seller::OrdersController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :ensure_seller

  def index
    orders = Order.joins(:order_items).where(order_items: { product_id: current_user.products.pluck(:id) }).distinct.includes(:user, :order_items)
    render json: orders
  end

  def update
    order = Order.find(params[:id])
    
    # Ensure the seller owns products in this order
    unless order.order_items.where(product_id: current_user.products.pluck(:id)).exists?
      return render json: { error: "Unauthorized" }, status: :forbidden
    end
    
    if order.update(order_params)
      render json: order
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def ensure_seller
    unless current_user.seller?
      render json: { error: "Only sellers can access this resource" }, status: :forbidden
    end
  end

  def order_params
    params.require(:order).permit(:status)
  end
end