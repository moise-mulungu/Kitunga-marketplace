class Api::V1::OrdersController <  Api::V1::BaseController
  before_action :authenticate_user!, except: [ :index, :show ]

  def index
    orders = Order.all

    # Filter orders for a specific customer (client dashboard)
    orders = orders.where(user_id: params[:customer_id]) if params[:customer_id].present?

    # Filter orders containing products from a specific seller (seller dashboard)
    if params[:seller_id].present?
      seller_product_ids = Product.where(user_id: params[:seller_id]).pluck(:id)
      orders = orders.joins(:order_items).where(order_items: { product_id: seller_product_ids }).distinct
    end

    render json: orders
  end

  def show
    order = Order.find(params[:id])
    render json: order
  end

  def create
    order = Order.new(order_params)
    if order.save
      render json: order, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    order = Order.find(params[:id])
    if order.update(order_params)
      render json: order
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    order = Order.find(params[:id])
    order.destroy
    head :no_content
  end

  private

  def order_params
    params.require(:order).permit(:user_id, :status, :total_amount)
  end
end
