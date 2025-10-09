class AddProviderAndPaidAtToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :provider, :string
    add_column :payments, :paid_at, :datetime
  end
end
