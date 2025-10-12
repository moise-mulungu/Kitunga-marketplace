class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :price, :quantity, :category, :available
  belongs_to :user
  has_many :order_items
end
