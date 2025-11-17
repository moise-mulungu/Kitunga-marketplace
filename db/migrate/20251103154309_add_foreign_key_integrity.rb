class AddForeignKeyIntegrity < ActiveRecord::Migration[8.0]
  def change
    # Only add the foreign key if it doesn't already exist
    unless foreign_key_exists?(:payments, :orders)
      add_foreign_key :payments, :orders, on_delete: :cascade
    end

    unless foreign_key_exists?(:order_items, :orders)
      add_foreign_key :order_items, :orders, on_delete: :cascade
    end

    unless foreign_key_exists?(:order_items, :products)
      add_foreign_key :order_items, :products, on_delete: :cascade
    end

    unless foreign_key_exists?(:products, :users)
      add_foreign_key :products, :users, on_delete: :nullify
    end

    unless foreign_key_exists?(:orders, :users)
      add_foreign_key :orders, :users, on_delete: :nullify
    end

    unless foreign_key_exists?(:admin_action_logs, :users)
      add_foreign_key :admin_action_logs, :users, column: :admin_id, on_delete: :cascade
    end
  end
end
