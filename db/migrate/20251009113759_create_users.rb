class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :full_name
      t.string :email
      t.string :password_digest
      t.string :role
      t.string :business_name
      t.string :category
      t.string :address
      t.string :phone

      t.timestamps
    end
  end
end
