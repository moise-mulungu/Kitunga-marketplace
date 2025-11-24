class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, :subtotal, presence: true

  before_validation :ensure_unit_price_and_subtotal

  def ensure_unit_price_and_subtotal
    # If product has price, set unit_price if missing.
    self.unit_price ||= product&.price
    self.subtotal = (unit_price.to_d * quantity.to_i).round(2)
  end
end
