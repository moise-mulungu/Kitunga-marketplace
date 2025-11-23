class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  # Return decimal (BigDecimal) total
  def total_amount
    cart_items.sum('COALESCE(subtotal, 0.0)')
  end

  # Return hash suitable for JSON
  def as_json_with_items
    {
      id: id,
      user_id: user_id,
      total_amount: total_amount.to_d.to_s('F'),
      items: cart_items.includes(product: { images_attachments: :blob }).map do |it|
        {
          id: it.id,
          product_id: it.product_id,
          title: it.product&.title,
          image_url: it.product&.image_url.is_a?(String) ?
            it.product.image_url :
            (it.product.images.attached? ? Rails.application.routes.url_helpers.url_for(it.product.images.first) : nil),
          quantity: it.quantity,
          unit_price: it.unit_price.to_s('F'),
          subtotal: it.subtotal.to_s('F')
        }
      end
    }
  end

end
