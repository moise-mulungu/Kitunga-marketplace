class AddFieldsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :slug, :string
    add_column :products, :featured, :boolean, default: false
    add_column :products, :sold_count, :integer, default: 0
    add_column :products, :tags, :string, array: true, default: []
  end
end
