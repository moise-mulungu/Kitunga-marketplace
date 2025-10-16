class AddConfirmableAndTwoFactorToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      # Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email

      # Two-factor (TOTP)
      t.string :otp_secret
      t.boolean :otp_required_for_login, default: false

      # Omniauth provider info
      t.string :provider
      t.string :uid
    end

    add_index :users, :confirmation_token, unique: true
    add_index :users, %i[provider uid]
  end
end
