class Api::V1::OrderItemsController < ApplicationController
  before_action :set_order_item, only: [:show, :update, :destroy]

  # GET /api/v1/order_items
  def index
    order_items = OrderItem.all
    render json: order_items
  end

  # GET /api/v1/order_items/:id
  def show
    render json: @order_item
  end

  # POST /api/v1/order_items
  def create
    order_item = OrderItem.new(order_item_params)
    if order_item.save
      render json: order_item, status: :created
    else
      render json: { errors: order_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/order_items/:id
  def update
    if @order_item.update(order_item_params)
      render json: @order_item
    else
      render json: { errors: @order_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/order_items/:id
  def destroy
    @order_item.destroy
    head :no_content
  end

  private

  def set_order_item
    @order_item = OrderItem.find(params[:id])
  end

  def order_item_params
    params.require(:order_item).permit(:order_id, :product_id, :quantity, :price, :subtotal)
  end
end
