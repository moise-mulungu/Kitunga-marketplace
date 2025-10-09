class AddDefaultsToOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_default :orders, :status, from: nil, to: "pending"
    change_column_default :orders, :payment_status, from: nil, to: "unpaid"
  end
end
