class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :category_type, :product_count

  has_many :products, serializer: ProductSerializer

  def product_count
    object.products.size
  end
end
