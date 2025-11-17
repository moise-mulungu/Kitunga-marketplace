class UpdateForeignKeyDeleteRules < ActiveRecord::Migration[8.0]
  def change
    # Drop existing FKs and recreate them with correct on_delete behavior

    remove_foreign_key :payments, :orders
    add_foreign_key :payments, :orders, on_delete: :cascade

    remove_foreign_key :order_items, :orders
    add_foreign_key :order_items, :orders, on_delete: :cascade

    remove_foreign_key :order_items, :products
    add_foreign_key :order_items, :products, on_delete: :nullify

    remove_foreign_key :products, :users
    add_foreign_key :products, :users, on_delete: :nullify

    remove_foreign_key :orders, :users
    add_foreign_key :orders, :users, on_delete: :nullify

    remove_foreign_key :products, :categories
    add_foreign_key :products, :categories, on_delete: :nullify
  end
end
