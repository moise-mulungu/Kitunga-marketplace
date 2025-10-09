class UpdateProductsAddAvailableAndPrecision < ActiveRecord::Migration[8.0]
  def change
    change_column :products, :price, :decimal, precision: 10, scale: 2
    add_column :products, :available, :boolean, default: true
  end
end
