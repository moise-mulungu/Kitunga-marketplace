class AddTrackingFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :shipping_address, :string
    add_column :orders, :payment_method, :string
    add_column :orders, :reference_code, :string
    add_index  :orders, :reference_code, unique: true
  end
end
