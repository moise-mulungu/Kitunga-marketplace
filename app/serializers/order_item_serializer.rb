class OrderItemSerializer < ActiveModel::Serializer
  attributes :id, :order_id, :product_id, :quantity, :price, :subtotal, :created_at, :updated_at
  belongs_to :order
  belongs_to :product
end
