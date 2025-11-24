class PaymentSerializer < ActiveModel::Serializer
  attributes :id, :order_id, :amount, :payment_method, :status
  belongs_to :order
end
