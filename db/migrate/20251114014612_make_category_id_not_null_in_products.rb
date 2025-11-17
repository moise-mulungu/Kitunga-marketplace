class MakeCategoryIdNotNullInProducts < ActiveRecord::Migration[8.0]
  def up
    # 1. Create a fallback category if it doesn't exist
    uncategorized = Category.find_or_create_by!(
      name: "Uncategorized",
      slug: "uncategorized",
      category_type: "product"
    )

    # 2. Assign any existing NULL category_id to this fallback
    Product.where(category_id: nil).update_all(category_id: uncategorized.id)

    # 3. Now enforce NOT NULL
    change_column_null :products, :category_id, false
  end

  def down
    change_column_null :products, :category_id, true
  end
end
