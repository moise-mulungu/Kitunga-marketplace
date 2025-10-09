class Product < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  validates :title, :price, :quantity, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :available, -> { where(available: true) }
end

