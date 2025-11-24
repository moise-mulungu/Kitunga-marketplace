class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.bigint :user_id, index: true, null: true
      t.timestamps
    end

    add_foreign_key :carts, :users, on_delete: :nullify
  end
end
