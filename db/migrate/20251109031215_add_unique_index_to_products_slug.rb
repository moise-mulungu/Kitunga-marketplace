class AddUniqueIndexToProductsSlug < ActiveRecord::Migration[8.0]
  def change
    add_index :products, :slug, unique: true
  end
end
