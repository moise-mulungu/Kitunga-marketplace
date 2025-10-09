class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_one :payment, dependent: :destroy

  enum :status, { pending: "pending", completed: "completed", cancelled: "cancelled" }
  enum :payment_status, { unpaid: "unpaid", paid: "paid", refunded: "refunded" }

  before_save :calculate_total_amount

  private

  def calculate_total_amount
    self.total_amount = order_items.sum("quantity * price")
  end
end
