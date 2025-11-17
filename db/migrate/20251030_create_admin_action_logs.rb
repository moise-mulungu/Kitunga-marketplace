class CreateAdminActionLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_action_logs do |t|
      t.integer :admin_id, null: false
      t.string :action, null: false
      t.text :details

      t.timestamps
    end
    add_index :admin_action_logs, :admin_id
    add_index :admin_action_logs, :action
  end
end
