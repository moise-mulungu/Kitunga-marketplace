class RenameJwtDenylistsToJwtDenylist < ActiveRecord::Migration[8.0]
  def change
     rename_table :jwt_denylists, :jwt_denylist
  end
end
