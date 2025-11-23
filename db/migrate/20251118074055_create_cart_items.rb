class CreateCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_items do |t|
      t.bigint :cart_id, null: false
      t.bigint :product_id, null: false
      t.integer :quantity, default: 1, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :subtotal, precision: 12, scale: 2, null: false
      t.timestamps
    end

    add_index :cart_items, :cart_id
    add_index :cart_items, :product_id
    add_foreign_key :cart_items, :carts, on_delete: :cascade
    add_foreign_key :cart_items, :products, on_delete: :nullify
  end
end
