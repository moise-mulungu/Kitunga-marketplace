class OrderSerializer < ActiveModel::Serializer
  attributes :id , :user_id, :status, :total_amount, :created_at, :updated_at
  belongs_to :user
  has_many :order_items
end
