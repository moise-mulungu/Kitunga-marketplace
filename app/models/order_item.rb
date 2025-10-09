class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  before_save :set_price_and_subtotal

  private

  def set_price_and_subtotal
    self.price = product.price
    self.subtotal = price * quantity
  end
end
