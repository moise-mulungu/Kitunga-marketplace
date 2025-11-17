class AddCurrencyAndMetaToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :currency, :string
    add_column :payments, :meta, :jsonb
  end
end
