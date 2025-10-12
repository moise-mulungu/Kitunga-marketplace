class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :email, :role, :business_name, :category, :address, :phone, :active, :created_at, :updated_at
  has_many :products
  has_many :orders
  has_many :payments
end
