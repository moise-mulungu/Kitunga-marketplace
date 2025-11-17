class AddCategoryRefToProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :category, foreign_key: true, index: true
  end
end
