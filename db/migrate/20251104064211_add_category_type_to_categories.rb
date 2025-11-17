class AddCategoryTypeToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :category_type, :string, null: false, default: "product"
  end
end
