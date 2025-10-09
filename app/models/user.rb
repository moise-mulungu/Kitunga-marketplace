class User < ApplicationRecord
  has_secure_password

  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :payments, through: :orders

  enum :role, { customer: "customer", seller: "seller", admin: "admin" }

  validates :full_name, :email, presence: true
  validates :email, uniqueness: true

  def seller?
    role == "seller"
  end

  def admin?
    role == "admin"
  end
end
